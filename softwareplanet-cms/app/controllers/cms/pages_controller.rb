require_dependency "cms/application_controller"

# This controller provides a single request point to the generating of Cms files
# for an application. It provides multilingual support and checks the admin privileges.

module Cms
  class PagesController < ApplicationController
    before_filter :all_locales_redirect, :check_aloha_enable

    ALLOW_COMPILED_CACHE = false

    def show
      #response.headers["Expires"] = 1.year.from_now.httpdate
      #@t1 = Time.now
      return unless all_locales_redirect
      @layout = params[:layout]

      @without_cache = !ALLOW_COMPILED_CACHE || check_admin

      if @without_cache # do not display cached:
        @html, @wrapper_id, @stylesheets, @seo_tags, @head_content = Page.compose(@layout, @application_data)
          # images count decreased for faster page loading
          #@images = Source.where(:type => SourceType::IMAGE)[] if check_admin
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
        render(:text => @compiled_layout)
        #p "RENDERED IN:"
        #p (Time.now - @t1)
        return
      end

      @images = Source.find_source_by_type(SourceType::IMAGE)

      #@html, @wrapper_id, @stylesheets, @seo_tags = Page.compose(@layout, @application_data)
      #@images = Source.where :type => SourceType::IMAGE if check_admin
      # images count decreased for faster page loading
      #@images = @images[0..10] if @images
    #rescue => e
    # puts e.backtrace
    # @fail_reason = e.message
    # render :action => "404", :layout => false and return
    end

  end
end