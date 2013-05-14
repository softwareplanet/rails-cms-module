require_dependency "cms/application_controller"

module Cms
  class SourceCodeController < ApplicationController
    protect_from_forgery :except => [:upload]
    before_filter :admin_access
    before_filter :check_aloha_enable

    def edit_source_code
      @sourceObject = Source.find_by_id(params[:id])
      if @sourceObject.type == SourceType::CSS && @sourceObject.get_data.length > 0
        from = @sourceObject.data.index("\n")+1
        to = -@sourceObject.data.reverse.index("\n")-1
        @sourceObject.data = @sourceObject.data[from..to]
      end

    end

    def update_source_code
      #fix me!
      @sourceObject = Source.find_by_id(params[:id])
      unless @sourceObject.nil?
        # rename
        @sourceObject.name = params[:name] unless params[:name].nil?
        # data change
        @sourceObject.set_data(params[:data]) unless params[:data].nil?

        if @sourceObject.type == SourceType::CSS
          @sourceObject.set_data('#' + @sourceObject.get_source_target.get_source_id + '{/*do not remove first and last line manually!*/' + "\n" + @sourceObject.get_data + "\n" + '}/*do not remove first and last line manually!*/')
        end

        @sourceObject.flash!
      end
    end

  end
end
