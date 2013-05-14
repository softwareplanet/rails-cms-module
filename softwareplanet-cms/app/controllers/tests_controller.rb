require_dependency "cms/application_controller"

class TestsController < ApplicationController

  def index
    text_to_render = "SANDBOX v1.0"
    render :text => text_to_render
  end
end