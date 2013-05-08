require './../app/models/cms/source'
require './../app/models/cms/adapter'
require './../app/models/cms/adapter_stable'
require './../app/models/cms/source_type'
require './../config/initializers/public_constants'

module Cms
  class Test
    require_relative 'test_suite'
    include TestSuite
    def self.base_folder
      TEST_SOURCE_FOLDER
    end
    def base_folder
      Test.base_folder
    end

    PREPARE = ->() {
      FileUtils.rm_rf(Test.base_folder)
    }

    ############################################
    #TESTS:

    def create_sample_sources
      @layout1 = Source.create(:name => 'layout1', :type => SourceType::LAYOUT)
      @layout2 = Source.create(:name => 'layout2', :type => SourceType::LAYOUT)
      @layout3 = Source.create(:name => 'layout3', :type => SourceType::LAYOUT)
      @layout4 = Source.create(:name => 'layout4', :type => SourceType::LAYOUT)
      @layout5 = Source.create(:name => 'layout5', :type => SourceType::LAYOUT)
      @css1 = Source.create(:name => 'css1.css', :type => SourceType::CSS)
      @css2 = Source.create(:name => 'css2.css', :type => SourceType::CSS)
      @css3 = Source.create(:name => 'css3.css', :type => SourceType::CSS)
      @css4 = Source.create(:name => 'css4.css', :type => SourceType::CSS)
      @css5 = Source.create(:name => 'css5.css', :type => SourceType::CSS)
    end

    def test_attach_to_source
      create_sample_sources
      @layout1.attach_to(@layout2)
      assert_equal(@layout1.name, '1-tar-layout2-tar-layout1')
      @layout1.attach_to(@layout3)
      assert_equal(@layout1.name, '1-tar-layout3-tar-layout1')
      assert_equal(@layout3.get_attach(SourceType::LAYOUT).get_source_path, @layout1.get_source_path)
    end

    def test_detach
      create_sample_sources
      @layout1.attach_to(@layout2)
      assert_equal(@layout1.name, '1-tar-layout2-tar-layout1')
      @layout1.detach
      assert_equal(@layout1.name, 'layout1')
    end

    def test_update_dependencies_after_attach
      create_sample_sources
      @layout1.attach_to(@layout2)
      @layout2.attach_to(@layout3)
      assert_equal(@layout3.get_attach(SourceType::LAYOUT).get_attach(SourceType::LAYOUT).get_self_name, 'layout1')
    end

    ############################################
    Test.new.runner(PREPARE)
  end
end