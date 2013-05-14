require_dependency "cms/application_controller"

module Cms
  class GalleryController < ApplicationController
    protect_from_forgery :except => [:upload]
    before_filter :admin_access
    before_filter :check_aloha_enable

    def upload
      uploaded_io = params[:Filedata]
      render :nothing => true and return unless uploaded_io
      to_dir = params[:to_dir]
      uploaded_filename = uploaded_io.original_filename

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
      @img_src = Source.new(:type => SourceType::IMAGE, :name => basename + '.' + extension, :path => to_dir)
      @img_src.data = uploaded_io.read
      @img_src.flash!
      @images = [@img_src]
    end

    def upload_success
      @last_image_name = session[:last_image_name]
      session[:last_image_name] = nil
      @img = Source.find_by_name(@last_image_name).first
    end

    def delete_image
      File.delete(params[:path])
    end

    def rename_image
      old_filepath = params[:path]
      new_filepath = File.dirname(params[:path]) + '/' + params[:new_name]
      File.rename(old_filepath,new_filepath)
      @new_id = params[:id].gsub(params[:old_name],params[:new_name])
      @image = Source.get_source_by_id(@new_id)
    end

    def get_images
      @images = Source.where :type => SourceType::IMAGE
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
              @directory = Source.create_folder(params)
            when 'rename_folder'
              @new_filepath = Source.rename_dir(params)
              @old_name = params[:old_name]

          end
        when "load"
      end
    end


  end
end
