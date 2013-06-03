require_dependency "cms/application_controller"

# This controller provides a single request point to the generating of Cms files
# for an application. It provides multilingual support and checks the admin privileges.

module Cms
  class PagesController < ApplicationController
    before_filter :all_locales_redirect, :check_aloha_enable

    ALLOW_COMPILED_CACHE = true

    def default_layout
      cms_attributes = Source.get_cms_settings_attributes
      default_layout_id = cms_attributes.default_layout_id
      default_layout_name = Source.get_source_by_id(default_layout_id)
      render :text => 'SoftwarePlanet CMS<br>Default layout has not been set.' and return if default_layout_name.nil?
      redirect_to :action => 'show', :layout => default_layout_name.get_source_name
    end

    def show
      return unless all_locales_redirect

      @layout = params[:layout]

      @without_cache = !ALLOW_COMPILED_CACHE || check_admin

      if @without_cache # do not display cached:
        @html, @wrapper_id, @stylesheets, @seo_tags, @head_content = Page.compose(@layout, @application_data)
      else
        layout_name = @layout
        lang_path = @application_data[:lang]
        compiled_file_folder = Source.get_source_folder(SourceType::COMPILED) + lang_path + "/"
        compiled_file_path = compiled_file_folder + layout_name
        @compiled_layout = File.read(compiled_file_path) if File.exists?(compiled_file_path)
        if @compiled_layout.nil?
          @html, @wrapper_id, @stylesheets, @seo_tags, @head_content = Page.compose(layout_name, @application_data)
          @compiled_file_content = Haml::Engine.new(@html, :format => :html5).render(Object.new, :app => @application_data )
          @compiled_layout = render_to_string

          FileUtils.mkpath(compiled_file_folder) unless File.exists?(compiled_file_folder)
          File.open(compiled_file_path, "w") do |file|
            file.write(@compiled_layout.force_encoding('utf-8'))
          end
        end
        render(:text => @compiled_layout) and return
      end
      @images = Source.find_source_by_type(SourceType::IMAGE).select{|i|i.filename != 'robots.txt'}

      # remove public
      @images = @images.collect{|i|
        i.path = ''
        i
      }
    end

  end
end