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

    #
    # CMS Render action
    #
    def show
      return unless all_locales_redirect
      @admin_view_mode = check_admin && params["adminmode"] == "1"
      @without_cache = !ALLOW_COMPILED_CACHE || @admin_view_mode
      @layout = params[:layout]
      @images = Page.get_sorted_gallery_images if check_admin

      if @without_cache # do not display cached:
        @html, @wrapper_id, @stylesheets, @seo_tags, @head_content = Page.compose(@layout, @application_data)
        render and return
      end

      lang_path = @application_data[:lang]
      @compiled_layout = Page.get_compiled_source(@layout, lang_path)

      if @compiled_layout.nil?
        @html, @wrapper_id, @stylesheets, @seo_tags, @head_content = Page.compose(@layout, @application_data)
        @compiled_file_content = Haml::Engine.new(@html, :format => :html5).render(Object.new, :app => @application_data )
        @compiled_layout = render_to_string
        Page.create_compiled_source(@compiled_layout, @layout, lang_path)
      end
      render(:text => @compiled_layout) and return
    end

  end
end