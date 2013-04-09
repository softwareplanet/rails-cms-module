require_dependency "devcms/application_controller"
module Devcms
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
      type = params[:type]
      name = params[:name]
      address = params[:address]
      no_show = params[:no_show]
      no_publish = params[:no_publish]
      keywords = params[:keywords]
      description = params[:description]

      @source = Source.new(:type => type, :name => name)
      @source.save
      @css = Source.new(:type => SourceType::CSS, :target => @source)
      @css.save
      @seo = Source.new(:type => SourceType::SEO, :target => @source)
      @seo.save
    end

    # GET /source_manager/1/edit
    def edit
      @sourceObject = Source.find_by_id(params[:id])
      render :nothing => true and return if @sourceObject.nil?
      @sourceObject.get_attach_or_create
      if @sourceObject.type == SourceType::CSS && @sourceObject.data.length > 0

        from = @sourceObject.data.index("\n")+1
        to = -@sourceObject.data.reverse.index("\n")-1
        @sourceObject.data = @sourceObject.data[from..to]
      end
    end

    # PUT /source_manager/1
    def update
      @sourceObject = Source.find_by_id(params[:id])
      #@cloned = @sourceObject.dup
      @sourceObject.load!
      unless @sourceObject.nil?
        # rename
        @sourceObject.name = params[:name] unless params[:name].nil?
        # data change
        @sourceObject.data = params[:data] unless params[:data].nil?
        # add scss parent
        if @sourceObject.type == SourceType::CSS
          @sourceObject.data = ('#' + @sourceObject.get_target.get_id + '{/*do not remove first and last line manually!*/' + "\n" + @sourceObject.data + "\n" + '}/*do not remove first and last line manually!*/')
        end
        #@cloned.delete!
        @sourceObject.save!
      end
    end

    # DELETE /page_layouts/1
    def destroy
      @sourceObject = Source.find_by_id(params[:id])
      begin
        @sourceObject.delete!
      rescue ActiveRecord::RecordInvalid
      end
    end

    def upload
      uploaded_io = params[:Filedata]
      uploaded_filename = uploaded_io.original_filename

      basename = File.basename(uploaded_filename, '.*')
      extension = File.extname(uploaded_filename)[1..-1]

      appendix = 0
      unless Source.where(:name => basename).empty?
        while appendix < 100
          appendix+=1
          break if Source.where(:name => basename + appendix.to_s).empty?
        end
        raise "File with such name already exists!" if appendix == 100
        basename = basename + appendix.to_s
      end

      @img_src = Source.new(:type => SourceType::IMAGE, :name => basename, :extension => extension)
      @img_src.data = uploaded_io.read
      @img_src.save!
      session[:last_image_name] = @img_src.name
      @image = Source.find_by_id(@img_src.get_id)
    end

    def upload_success
      @last_image_name = session[:last_image_name]
      session[:last_image_name] = nil
      @img = Source.find_by_name(@last_image_name).first
    end

    def delete_image
      @source = Source.find_by_name(params[:name]).first
      @source.delete
    end

    def rename_image
      @sourceObject = Source.find_by_id(params[:id])
      @old_id = @sourceObject.get_id
      @sourceObject.rename(params[:name])
    end

    def get_images
      @images = Source.where :type => SourceType::IMAGE
    end

    # Actions related to ToolBar
    def tool_bar
      @object = params[:object]
      @activity = params[:activity]
    end

    def menu_bar
      @object = params[:object]
      @activity = params[:activity]
      case @activity
        when "load"
          case @object
            when "structure"
              @layouts = Source.where :type => SourceType::LAYOUT
            when "gallery"
              @images = Source.where :type => SourceType::IMAGE
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

  end
end
