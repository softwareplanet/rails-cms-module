require_dependency "devcms/application_controller"

class TestsController < ApplicationController
  def index
    d = Diamond.new('diamond_1')
    d.save!
    render :text => "SANDBOX v1.0"
  end
end