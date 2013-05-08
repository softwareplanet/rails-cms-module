require './../app/models/cms/source'
require './../app/models/cms/adapter_stable'
require './../app/models/cms/source_type'
require './../config/initializers/public_constants'

module Cms
  class Test
    require_relative 'test_suite'
    include TestSuite
    def self.source_folder(source_type=nil)
      source_type.nil? ? TEST_SOURCE_FOLDER : TEST_SOURCE_FOLDERS[source_type].chomp('/')
    end
    def source_folder(source_type=nil)
      Test.source_folder(source_type)
    end

    PREPARE = ->() {
      FileUtils.rm_rf(Test.source_folder)
    }

    ############################################
    #TESTS:

    def create_sample_sources
      @layout1 = Source.build(:name => 'layout1', :type => SourceType::LAYOUT)
      @layout2 = Source.build(:name => 'layout2', :type => SourceType::LAYOUT)
      @layout3 = Source.build(:name => 'layout3', :type => SourceType::LAYOUT)
      @layout4 = Source.build(:name => 'layout4', :type => SourceType::LAYOUT)
      @layout5 = Source.build(:name => 'layout5', :type => SourceType::LAYOUT)
      @css1 = Source.build(:name => 'css1.css', :type => SourceType::CSS)
      @css2 = Source.build(:name => 'css2.css', :type => SourceType::CSS)
      @css3 = Source.build(:name => 'css3.css', :type => SourceType::CSS)
      @css4 = Source.build(:name => 'css4.css', :type => SourceType::CSS)
      @css5 = Source.build(:name => 'css5.css', :type => SourceType::CSS)
    end

    def create_nested_sources
      @parent_layout1 = Source.build(:name => 'layout1', :type => SourceType::LAYOUT)
      @child_layout2 = Source.build(:name => 'layout2', :type => SourceType::LAYOUT, :target => @parent_layout)
    end

    def test_build
      @css1 = Source.build(:name => 'css1.css', :type => SourceType::CSS)
      @layout1 = Source.build(:name => 'layout1', :type => SourceType::LAYOUT, :attach => @css1)
      assert_equal(@css1.get_source_filepath, "#{source_folder(SourceType::CSS)}/1-tar-layout1-tar-css1.css")
      assert_equal(@css1.target, @layout1)

      @image1 = Source.build(:name => 'image.png', :type => SourceType::IMAGE, :target => @css1)
      assert_equal(@image1.get_source_name, 'image.png')
      assert_equal(@image1.get_source_filename, '3-tar-css1.css-tar-image.png')
      assert_equal(@image1.get_source_filepath, "#{source_folder(SourceType::IMAGE)}/3-tar-css1.css-tar-image.png")

      @image2 = Source.get_source_by_id(@image1.get_source_id)
      assert_equal(@image2.get_source_name, 'image.png')
      assert_equal(@image2.get_source_filepath, "#{source_folder(SourceType::IMAGE)}/3-tar-css1.css-tar-image.png")
      assert_equal(@image2.get_source_filename, '3-tar-css1.css-tar-image.png')
    end

    def test_naming
      create_sample_sources
      assert_equal( @layout1.get_source_name, 'layout1')
      assert_equal( @layout1.get_source_filename, 'layout1')
      assert_equal( @layout1.get_source_filepath, "#{source_folder(SourceType::LAYOUT)}/layout1")
    end

    def test_detach
      create_sample_sources
      @layout1.attach_to(@layout2)
      assert_equal(@layout1.name, '1-tar-layout2-tar-layout1')
      @layout1.detach
      assert_equal(@layout1.name, 'layout1')
    end

    def test_attach_to_source
      create_sample_sources
      @layout1.attach_to(@layout2)
      assert_equal(@layout1.name, '1-tar-layout2-tar-layout1')
      @layout1.attach_to(@layout3)
      assert_equal(@layout1.name, '1-tar-layout3-tar-layout1')
      assert_equal(@layout3.get_source_attaches(SourceType::LAYOUT)[0].get_source_path, @layout1.get_source_path)
    end


    def test_update_dependencies_after_attach
      create_sample_sources
      @layout1.attach_to(@layout2)
      @layout2.attach_to(@layout3)
      assert_equal(@layout3.get_source_attaches(SourceType::LAYOUT)[0].get_source_attaches(SourceType::LAYOUT)[0].get_source_name, 'layout1')
    end

    ############################################
    Test.new.runner(PREPARE)
  end
end