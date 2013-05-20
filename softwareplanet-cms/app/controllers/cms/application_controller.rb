#module Cms
  class Cms::ApplicationController < ApplicationController
    before_filter :set_locale, :setup_application_data
    protect_from_forgery

    USE_COOKIES = false

    # If request locale not specified, redirect to session locale:
    def all_locales_redirect
      if params[:locale].blank? && !!session[:locale] && !!params[:layout]
        redirect_to "/#{session[:locale]}/#{params[:layout]}" and return false
      end
      return true
    end

    # Define all content variables:
    def setup_application_data
      @application_data ||= {}
      @application_data[:layout] = params[:layout]
      @application_data[:time] = Time.now
      @application_data[:lang] = Cms::SiteLanguage.find_by_url(session[:locale]).name
      @application_data[:locale] = session[:locale]
      @application_data[:admin?] = session[:logged]
    end

    def initialize
      super
      I18n.default_locale = "eng"
    end

    def set_locale
      # get locale from request url
      request_locale = params[:locale]
      # get locale from cookies
      if request_locale.blank? && USE_COOKIES
        request_locale = Cms::SiteLanguage.find_by_url(cookies[:locale]).url unless cookies[:locale].blank?
      end
      # get first locale from database
      if request_locale.blank?
        request_locale = Cms::SiteLanguage.first.url
      end
      # search for requested locale in database
      site_locale = Cms::SiteLanguage.find_by_url(request_locale.downcase) || Cms::SiteLanguage.first
      # save correct locale in cookies
      if USE_COOKIES
        cookies[:lang] = request_locale
      end
      # save locale state
      session[:locale] = site_locale.url
      I18n.locale = site_locale.url || I18n.default_locale
    end

    def check_admin
      return false if (params["admin"] == "false")
      session[:logged] == true
    end

    def admin_access
      if (request.url.include?("/adm") ||
          request.url.include?("/page_layouts") ||
          request.url.include?("/page_contents") ||
          request.url.include?("/gallery") ||
          request.url.include?("/source_code") ||
          request.url.include?("/source_manager")) && !check_admin
        flash[:error] =  t("access.denied")
        redirect_to root_path and return false
      else
        @logout_button = true
        return true
      end
    end

    def check_aloha_enable
      @aloha_enable = check_admin
    end
  end
#end