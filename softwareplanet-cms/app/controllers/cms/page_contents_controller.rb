require_dependency "cms/application_controller"
module Cms
  class PageContentsController < ApplicationController
    before_filter :admin_access

    def aloha
      # delete cached
      t1 = Time.now
      dir_to_delete = Adapter.get_source_folder(SourceType::COMPILED)
      FileUtils.rm_rf(dir_to_delete)
      p "Time spent:"
      p (Time.now - t1)

      # Find edited content by id:
      @local = SiteLocal.find_or_create_by_tag_id params[:content_name]
      @local.update_attribute(:text, params[:content])
      render :nothing => true
    end

  end
end
