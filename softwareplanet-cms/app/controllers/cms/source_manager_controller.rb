require_dependency "cms/application_controller"

module Cms
  class SourceManagerController < ApplicationController
    protect_from_forgery
    before_filter :admin_access
    before_filter :check_aloha_enable

    # Show list of all sources, 'structure' panel:
    def index
      @layouts = Source.where(:type => SourceType::LAYOUT)
    end

    # Create new layout with specified settings. Layout name should be not empty and unique.
    def create
      layout_name = params[:name]
      begin
        raise I18n.t('create_layout_form.blank_address') if layout_name.blank?
        raise I18n.t('create_layout_form.wrong_address') if Source.find_source_by_name_and_type(layout_name, SourceType::LAYOUT).any?
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
      begin
        raise I18n.t('update_page_properties.blank_page_name') if layout_name.blank?
        existed_named_layout = Source.find_source_by_name_and_type(layout_name, SourceType::LAYOUT).first
        raise I18n.t('update_page_properties.name_already_exist') if existed_named_layout && existed_named_layout.get_source_id != layout_id
      rescue => error
        render :js => "alert('#{error}');" and return
      end
      begin
        @layout = Source.update_page(layout_id, params)
      rescue
        render :js => "alert('#{I18n.t('update_page_properties.error')}');" and return
      end

      @old_layout_id = layout_id
    end

    # Destroy source by id.
    def destroy
      source = Source.get_source_by_id(params[:id])
      source.eliminate! unless source.blank?
    end

    def set_default_layout
      layout_id = Source.get_source_by_id params[:id]
      #Source.get_cms_settings_source .default_layout_id
      1+1
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
              @default_layout_id = Source.get_cms_settings_attributes.default_layout_id
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
      case @activity
        when "click"
        when "load"
      end
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
      case @activity
        when "click"
        when "load"
      end
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
      case @activity
        when "click"
        when "load"
      end
    end

    def create_component
      component_name = params[:name]
      type = SourceType::CONTENT
      if component_name.blank?
        @message = I18n.t('create_component_form.blank_name')
      elsif !Source.find_by_name_and_type(component_name, type).blank?
        @message = I18n.t('create_component_form.component_exist')
      else
        begin
          @component = Source.build(:type => type, :name => component_name)
          @css = Source.build(:type => SourceType::CSS, :name => component_name, :target => @component)
        rescue Exception => exc
          render :js => 'alert("' +  I18n.t('create_component_form.error') + '");'
          return
        end
        render 'create_component'
        return
      end
      render :js => 'alert("' +  @message + '");'
    end

    def save_component
      component_id = params[:id]
      component_name = params[:name]
      begin
        raise I18n.t('save_component_form.blank_name') if component_name.blank?
        existed_named_component = Source.find_source_by_name_and_type(component_name, SourceType::CONTENT).first
        raise I18n.t('save_component_form.component_exist') if existed_named_component && existed_named_component.get_source_id != component_id
      rescue => error
        render :js => "alert('#{error}');" and return
      end
      @component = Source.get_source_by_id(component_id)
      @old_component_id = @component.get_source_id
      @component.rename_source(component_name)
      render 'save_component'
    end

    # GET /source_manager/new
    def new
      render :nothing => true
    end

  end
end
