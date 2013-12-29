require_dependency "cms/application_controller"
module Cms
  class PageContentsController < ApplicationController
    before_filter :admin_access

    def aloha
      # delete cached
      Source.delete_compiled_sources
      # Find edited content by id:
      @local = SiteLocal.find_or_create_by_tag_id params[:content_name]
      @local.update_attribute(:text, params[:content])
      render :nothing => true
    end

  end
end
