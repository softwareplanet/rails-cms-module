require_dependency "cms/application_controller"
module Cms
  class SourceManagerController < ApplicationController

    protect_from_forgery :except => [:upload]

    before_filter :admin_access
    before_filter :check_aloha_enable

    # Display sources manage page
    def index
      #@img
      @layouts = Source.where :type => SourceType::LAYOUT
      #@contents = Source.where(:type => SourceType::CONTENT).reverse
      #@images = Source.where :type => SourceType::IMAGE
    end

    # GET /source_manager/new
    def new
      render :nothing => true
    end

    # POST /source_manager
    def create
      name = params[:name]
      if name.blank?
        @message = I18n.t('create_layout_form.blank_address')
      elsif !Source.find_source_by_name_and_type(name, SourceType::LAYOUT).blank?
        @message = I18n.t('create_layout_form.wrong_address')
      else
        @source = Source.create_page(params)
        @layout = @source['layout']
        render 'create'
        return
      end
      render :js => "alert('#{@message}');"
    end

    def edit_source
      @sourceObject = Source.find_by_id(params[:id])
    end

    # PUT /souSource.find_source_by_name_and_type("green", SourceType::LAYOUT).blank?rce_manager/1
    def update_source
      #fix me!
      @sourceObject = Source.find_by_id(params[:id])
      unless @sourceObject.nil?
        # rename
        @sourceObject.name = params[:name] unless params[:name].nil?
        # data change
        @sourceObject.data = params[:data] unless params[:data].nil?
        @sourceObject.flash!
      end
    end

    # DELETE /page_layouts/1
    def destroy
      source = Source.get_source_by_id(params[:id])
      source.eliminate! unless source.blank?
    end

    def upload
      uploaded_io = params[:Filedata]
      render :nothing => true and return unless uploaded_io
      to_dir = params[:to_dir]
      uploaded_filename = uploaded_io.original_filename.downcase

      basename = File.basename(uploaded_filename, '.*')
      extension = File.extname(uploaded_filename)[1..-1]
      appendix = 0
      get_source = Source.where(:name => basename, :path => to_dir)

      unless get_source.empty?
          while appendix < 1000
            appendix+=1
            get_source = Source.where(:name => basename + appendix.to_s, :path => to_dir)
            break unless !get_source.empty?
          end
          raise "File with such name already exists!" if appendix == 1000
          basename = basename + appendix.to_s
      end
      @img_src = Source.new(:type => SourceType::IMAGE, :name => basename, :extension => extension, :path => to_dir)
      @img_src.data = uploaded_io.read
      @img_src.save!
      session[:last_image_name] = @img_src.name
      @image = Source.find_by_id(@img_src.get_id)
      str = 'public/'
      line = @image.path
      @image.image_path = line[line.index(str) + str.size .. -1]
    end

    def upload_success
      @last_image_name = session[:last_image_name]
      session[:last_image_name] = nil
      @img = Source.find_by_name(@last_image_name).first
    end

    def delete_image
      name, extension = params[:full_name].split('.')
      image_dir = 'public/'
      path = image_dir + params[:path]
      @source = nil
      @sources = Source.find_by_name_and_extension(name, extension).select do |source|
        if source.path == path
          @source = source
        end
      end
      @source.delete
    end

    def properties

    end

    def reorder_layouts
      items = params[:items]
      list_id = params[:list_id]
      Source.reorder(items, list_id)
      render :nothing => true
    end

    def save_properties

      @layout_name = params[:id]
      title = params[:title]
      @address = params[:url]
      no_show = params[:no_show]
      no_publish = params[:no_publish]
      keywords = params[:keywords]
      description = params[:description]

      if @address.blank?
        @message = I18n.t('save_layout_form.blank_addressparh')

      elsif  /\W/.match(@address)
          @message = I18n.t('save_layout_form.wrong_address')

      elsif (@layout_name != @address) && (Source.find_by_name_and_type(@address, SourceType::LAYOUT).length > 0 )
          @message = I18n.t('save_layout_form.address_exist')

      else
        begin
          @css = Source.quick_attach(SourceType::LAYOUT,  @layout_name, SourceType::CSS)
          @seo = Source.quick_attach(SourceType::LAYOUT,  @layout_name, SourceType::SEO)
          @seo.data = "<title>#{title}</title>\n<meta name=\"keywords\" content=\"#{keywords}\"/>\n<meta name=\"description\" content=\"#{description}\"/>\n"
          @seo.save!

          if @layout_name != @address
            seo_path = @seo.get_source_folder + @seo.get_filename
            raise unless File.exist? seo_path
            File.rename(seo_path, @seo.get_source_folder + '1-tar-' + @address)

            css_path = @css.get_source_folder + @css.get_filename
            raise unless File.exist? css_path
            #before
            #css_type = SOURCE_TYPE_EXTENSIONS[SourceType::CSS]
            #File.rename(css_path, @css.get_source_folder + '1-tar-' + @address + '.' + css_type)
            #after
            File.rename(css_path, @css.get_source_folder + '1-tar-' + @address)
            #end
          end

          @layout = Source.find_by_name_and_type(@layout_name, SourceType::LAYOUT).first
          if !@layout
            @layout = Source.find_by_name_and_type(@layout_name, SourceType::HIDDEN_LAYOUT).first
          end

          @old_layout_id = @layout.get_id
          open_layouts = '/layouts/'
          hidden_layouts = '/hidden_layouts/'
          old_path = @layout.path + @layout_name

          if no_publish.nil?
            new_path = File.dirname(@layout.path) + open_layouts + @address
          else
            new_path = File.dirname(@layout.path) + hidden_layouts + @address
          end

          File.rename(old_path, new_path)
          @source = Source.find_by_name(@address).first

        rescue Exception => exc
          render :js => 'alert("' +  I18n.t('save_layout_form.wrong') + '");'
          return
        end
        render 'save_properties'
        return
      end
      render :js => 'alert("' +  @message + '");'
    end


    def rename_image
      @path =  'public/' + params[:path]
      @new_name = params[:new_name]
      @old_name = params[:old_name]
      @sourceObject = Source.where(:type => SourceType::IMAGE, :path => @path, :name => @old_name).first
      @sourceObject.image_path = params[:path]
      @sourceObject.rename(@new_name.downcase)
    end

    def get_images
      @images = Source.where :type => SourceType::IMAGE
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
              @layouts = Source.where(:type => SourceType::LAYOUT)
              @hiddens = Source.where(:type => SourceType::HIDDEN_LAYOUT).collect{ |source| source.hidden = true; source }
              @layouts |= @hiddens
            when "content"
              @layouts = Source.where(:type => SourceType::LAYOUT)
            when "components"
              @components = Source.where(:type => SourceType::CONTENT)
            when "gallery"
              if params[:path]
                @current_path = params[:path]
              else
                @current_path = SOURCE_FOLDERS[SourceType::IMAGE]
              end
              @images = Dir.glob(@current_path + "*.*")
              @images.map!{|image_path| File.basename(image_path)}
              #File@layouts.basename('/qwe/img.png')         =>  img.png
              #File.basename('/qwe/img.png','.*')    =>  img
              @result = []
              str = 'public/'
              @sources = Source.where :type => SourceType::IMAGE, :path => @current_path
              @sources.each { |source|
                @images.map { |image|
                  if source.get_filename == image
                    line = source.path
                    source.image_path = line[line.index(str) + str.size .. -1]
                    @result.push(source)
                  end
                }
              }

              @dirs = []
              Dir.glob(@current_path + '*').each { |file|
                if File.directory?(file)
                  dir = OpenStruct.new
                  dir.name = File.basename(file)
                  dir.path = @current_path
                  dir.size = Dir.glob(file + '/*').size
                  @dirs.push(dir)
                end
              }
              #render :nothing => true
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

    def panel_structure
      @activity = params[:activity]
      @object = params[:object]
      @data = params[:data]
      case @activity
        when 'drag_and_drop'
          Source.reorganize_by_ids(@object, @data)
        when 'click'
        when 'load'
          case @object
            when 'edit_properties'
              @layout = Source.find_by_id(params['layout_id'])
              @settings = Source.get_source_settings(params[:layout_id])
              @seo = @layout.get_source_attach(SourceType::SEO)
              @seo_tags = Source.parse_seo_tags(@seo)

=begin
              @layout_id = params[:layout_id]
              #@seo, @path = Source.quick_build_seo_with_path(@layout_id)
              @page_name = Source.quick_get_layout_name_by_id(@layout_id)
              #no_show = params[:no_show]
              @no_publish = @layout_id.match('pre1-id-').blank?
              @seo_id = @layout_id.gsub(/pre(1|8)-id-/, '1-tar-')
              @seo = Source.quick_attach(SourceType::LAYOUT,  @page_name, SourceType::SEO)
              @path = @seo.get_source_folder + @seo.name

              File.open(@path, "r").each_line  do |line|
                line = line.downcase()
                if line.slice('title')
                  str1 = "<title>"
                  str2 = "</title>"
                  @title = line[line.index(str1) + str1.size .. line.index(str2)-1]
                end
                if line.slice('keywords')
                  str = "content=\""
                  @keywords = line[line.index(str) + str.size .. -5]
                end
                if line.slice('description')
                  str = "content=\""
                  @description = line[line.index(str) + str.size .. -5]
                end
              end
=end
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

    def panel_gallery
      @activity = params[:activity]
      @object = params[:object]
      case @activity
        when "click"
          case @object
            when 'delete_folder'
              @path = params[:path]
              @name = params[:name]
              Source.delete_dir(@path + @name)
            when 'add_folder'
              path =  params[:path]
              folder_full_path = Source.mkdir(path)
              @dir = OpenStruct.new
              @dir.name = File.basename(folder_full_path)
              @dir.path = File.dirname(folder_full_path)
              @dir.size = Dir.glob(folder_full_path + '/*').size
              puts 1
            when 'rename_folder'
              @new_name = params[:new_name]
              @old_name = params[:old_name]
              @path = params[:path]
              @new_full_path = Source.rename_dir(@path + @old_name, @new_name)
              @new_path = File.dirname(@new_full_path) + '/'
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
          @component = Source.new(:type => type, :name => component_name)
          @component.save!
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
      component_name = params[:name]
      if component_name.blank?
        @message = I18n.t('save_component_form.blank_name')
      elsif !Source.find_by_name_and_type(component_name, SourceType::CONTENT).blank?
        @message = I18n.t('save_component_form.component_exist')
      else
        begin
          @component = Source.find_by_id(params[:id])
          path = @component.path
          old_name = @component.name
          File.rename(path + old_name,path + component_name)
          @component = Source.find_by_name_and_type(component_name, SourceType::CONTENT).first
          @old_id = params[:id]
        rescue Exception => exc
          render :js => 'alert("' +  I18n.t('save_component_form.error') + '");'
          return
        end
        render 'save_component'
        return
      end
      render :js => 'alert("' +  @message + '");'
    end
  end
end
