require_dependency "cms/application_controller"

module Cms
  class SourceManagerController < ApplicationController
    protect_from_forgery
    before_filter :admin_access
    before_filter :check_aloha_enable
    before_filter :localize

    # Show list of all sources, 'structure' panel:
    def index
      @layouts = Source.where(:type => SourceType::LAYOUT)
    end

    # Create new layout with specified settings. Layout name should be not empty and unique.
    def create
      layout_name = params[:name]
      begin
        raise I18n.t('panels.page_properties.blank_address') if layout_name.blank?
        raise I18n.t('panels.page_properties.wrong_address') if Source.find_source_by_name_and_type(layout_name, SourceType::LAYOUT).any?
      rescue => error
        render :js => "alert('#{error}');" and return
      end
      @layout = Source.create_page(params)
      render 'create'
    end

    # Update properties of existed layout.
    def update_page_properties
      layout_id = params[:id]
      layout_name = params[:name]
      raise I18n.t('update_page_properties.blank_page_name') if layout_name.blank?
      existed_named_layout = Source.find_source_by_name_and_type(layout_name, SourceType::LAYOUT).first
      raise I18n.t('update_page_properties.name_already_exist') if existed_named_layout && existed_named_layout.get_source_id != layout_id
      @layout = Source.update_page(layout_id, params)
      @old_layout_id = layout_id
    rescue => error
      render :js => "alert('#{I18n.t('update_page_properties.error')}:#{error}');" and return
    end

    # Destroy source by id.
    def destroy
      source = Source.get_source_by_id(params[:id])
      source.eliminate! unless source.blank?
    end

    def update_cms_settings
      Source.update_cms_properties params
      if session[:admin_locale_name] != params[:admin_locale_name]
        session[:cms_localize] = nil
        render :js => 'alert("Page will be reloaded to apply localization options");location.reload();' and return
      end
      render :js => 'alert("Updated");'
    end

    def reorder_sources
      items = params[:items]
      list_id = params[:list_id]
      # just for now:
      ordered_items_type = Source.get_source_by_id(items.first).type

      Source.set_order(list_id, items, ordered_items_type)
      render :nothing => true
    end

    # Actions related to ToolBar
    def tool_bar
      @object = params[:object]
      @activity = params[:activity]
      @path = params[:path]
    end

    def menu_bar
      @object = params[:object]
      @activity = params[:activity]
      case @activity
        when "load"
          case @object
            when "structure"
              @layouts_ids = Source.get_order(nil, SourceType::LAYOUT)
              @layouts = @layouts_ids.collect{|id| Source.get_source_by_id(id) }
            when "content"
              @layouts_ids = Source.get_order(nil, SourceType::LAYOUT)
              @layouts = @layouts_ids.collect{|id| Source.get_source_by_id(id) }
              #@layouts = Source.where(:type => SourceType::LAYOUT)
            when "components"
              @components_ids = Source.get_order(nil, SourceType::CONTENT)
              @components = @components_ids.collect{|id| Source.get_source_by_id(id) }
            when "gallery"
              @images_folder = Cms::SOURCE_FOLDERS[SourceType::IMAGE]
              @sources = Source.load_gallery(params)
            when "settings"
              @layouts = Source.find_source_by_type(SourceType::LAYOUT) || []
              attributes = Source.get_cms_settings_attributes
              @default_layout_id = attributes.default_layout_id
              @images_path = attributes.images_path
              SOURCE_FOLDER[SourceType::IMAGE] = @images_path
              @locales = ['English', "#{I18n.t('rus')}"]
              @admin_locale_name = attributes.admin_locale_name
              @show_locale_in_url = attributes.show_locale_in_url
          end
      end
    end

    def editor
      @object = params[:object]
      @activity = params[:activity]
      case @activity
        when "edit"
          @source = Source.find_by_id @object
      end
    end

    def panel_main
      @activity = params[:activity]
      @object = params[:object]
      @data = params[:data]
    end

    #
    #
    #
    def panel_structure
      @activity = params[:activity]
      @object = params[:object]
      @data = params[:data]
      case @activity
        when 'drag_and_drop'
          Source.reorganize_by_ids(@object, @data)
        when 'click'
          @layout = Source.find_by_id(params['layout_id'])
          @layouts_ids = Source.get_order(@layout.get_source_id, SourceType::LAYOUT)
          @sub_layouts = @layouts_ids.collect{|id| Source.get_source_by_id(id) }
          raise 'sub_layouts should be array' unless @sub_layouts.is_a?(Array)
        when 'load'
          case @object
            when 'edit_properties'
              @layout = Source.find_by_id(params['layout_id'])
              @settings_file = Source.get_source_settings_file(@layout.get_source_id)
              @settings = SourceSettings.new.read_source_settings(@settings_file)
            when 'edit_component'
              component_id = params[:component_id]
              @component = Source.find_by_id(component_id)
          end
      end
    end

    def panel_content
      @activity = params[:activity]
      @object = params[:object]
    end

    def panel_components
      @activity = params[:activity]
      @object = params[:object]
      case @activity
        when "click"
          case @object
            when 'panel_viewer'
              #"pre3-id-1-tar-green3"
              @layout_name = params[:layout_name]
          end
        when "load"
      end
    end

    def panel_settings
      @activity = params[:activity]
      @object = params[:object]
    end

    def create_component
      component_name = params[:name]
      type = SourceType::CONTENT
      raise I18n.t('create_component_form.blank_name') if component_name.blank?
      with_same_name = Source.find_by_name_and_type(component_name, type)
      raise I18n.t('create_component_form.component_exist') unless with_same_name.blank?
      @component = Source.build(:type => type, :name => component_name)
      @css = Source.build(:type => SourceType::CSS, :name => component_name+'.scss', :target => @component)
      render 'create_component' and return
    rescue Exception => error_message
      render :js => "alert('#{I18n.t('create_component_form.error')}:#{error_message}');" and return
    end

    def save_component
      component_id = params[:id]
      component_name = params[:name]
      raise I18n.t('save_component_form.blank_name') if component_name.blank?
      with_same_name = Source.find_source_by_name_and_type(component_name, SourceType::CONTENT).first
      raise I18n.t('save_component_form.component_exist') if with_same_name && with_same_name.get_source_id != component_id
      @old_component_id = component_id
      @component = Source.get_source_by_id(component_id)
      @component.rename_source(component_name)
      render 'save_component'
    rescue Exception => error_message
      render :js => "alert('#{I18n.t('create_component_form.error')}:#{error_message}');" and return
    end

    # GET /source_manager/new
    def new
      render :nothing => true
    end

  end
end
