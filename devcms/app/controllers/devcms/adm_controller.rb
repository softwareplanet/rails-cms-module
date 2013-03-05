require_dependency "devcms/application_controller"

module Devcms
  class AdmController < ApplicationController
    before_filter :admin_access, :except => [:login, :login_submit]

    def login
      @notice = flash[:notice]
    end

    def login_submit
      session[:logged] = params[:username] == ADMIN_NAME && params[:password] == ADMIN_PASS
      if check_admin
        redirect_to :action => :index
      else
         flash[:error] = t("login.wrong")
         redirect_to :action => :login
      end
    end

    def index
      redirect_to source_manager_index_path
    end

    def logout
      session[:logged] = nil
      redirect_to :action => :login
    end

    def reset
      dir_to_delete = Adapter.get_source_folder(SourceType::COMPILED)
      FileUtils.rm_rf(dir_to_delete)
      render :text => "COMPILED RESOURCES WERE DELETED"
    end

  end
end
