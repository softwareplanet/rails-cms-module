require_dependency "devcms/application_controller"

module Devcms
  class TestsController < ApplicationController

    def index
      render :text => "SANDBOX v1.0"
    end

  end
end
