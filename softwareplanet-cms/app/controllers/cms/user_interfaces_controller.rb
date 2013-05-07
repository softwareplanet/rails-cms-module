require_dependency "cms/application_controller"

module Cms
  class UserInterfacesController < ActionController::Base
    protect_from_forgery

    def set_locale
      cookies[:locale] = params[:lang]
      #url = Rails.application.routes.recognize_path(request.env['HTTP_REFERER'])
      layout = request.env['HTTP_REFERER'].split("/")[-1]
      #controller =  url[:controller]
      #layout = url[:layout]
      #action = url[:action]
      #if controller == "pages" && action == "show"
      @redirect_to = "/#{params[:lang]}/#{layout}" and return
      #end
    end

    def set_mode
      mode = params[:mode]
      if mode == "prod"
        session[:demo_mode] = false
      end
      if mode == "demo"
        session[:demo_mode] = true
      end
    end

  end
end
