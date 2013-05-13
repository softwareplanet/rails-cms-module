require_dependency "cms/application_controller"

module Cms
  class SourceCodeController < ApplicationController
    protect_from_forgery :except => [:upload]
    before_filter :admin_access
    before_filter :check_aloha_enable

    def edit_source_code
      @sourceObject = Source.find_by_id(params[:id])
    end

    def update_source_code
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

  end
end
