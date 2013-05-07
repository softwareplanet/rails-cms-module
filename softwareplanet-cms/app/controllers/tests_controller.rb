require_dependency "cms/application_controller"

class TestsController < ApplicationController

  def prepare
    FileUtils.rm_rf('data_source')
  end

  def test1_create_file
    prepare
    d = Diamond.new("Cullinan")
    d.data = 'The Cullinan diamond is the largest gem-quality diamond ever found, at 3106.75 carat (603.35 g, 1.37 lb) rough weight.[1] About 10.5 cm (4.1 inches) long in its largest dimension, it was found January 26, 1905, in the Premier No. 2 mine, near Pretoria, South Africa.'
    d.save!
    raise 'test1_create_file' unless File.exists?('/data_source/diamond/Cullinan')
  end

  def index

    text_to_render = "SANDBOX v1.0"

    ActiveFileTest::test_runner



    #test1_create_file


    #d = Diamond.new("Cullinan")
    #d.data = "The Cullinan diamond is the largest gem-quality diamond ever found, at 3106.75 carat (603.35 g, 1.37 lb) rough weight.[1] About 10.5 cm (4.1 inches) long in its largest dimension, it was found January 26, 1905, in the Premier No. 2 mine, near Pretoria, South Africa."

    #m = Material.new("Carbonium")
    #m.diamond
    #m.diamond = d
    #m.save!

    #d = Diamond.find_by_name("Cullinan")


    #puts d.data
    #text_to_render = m.diamond.inspect
    #d = Diamond.new('diamond_1')
    #d.data = "asdasdasd"
    #d.save!
    render :text => text_to_render
  end
end