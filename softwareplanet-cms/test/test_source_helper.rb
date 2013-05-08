require './../app/models/cms/source'
require './../app/models/cms/source_type'
require './../app/models/cms/source_helper'
require './../app/models/cms/adapter_stable'
require './../config/initializers/public_constants'

module Cms
  class Test
    require_relative 'test_suite'
    include TestSuite

    def self.get_test_folders
      TEST_SOURCE_FOLDERS.map {|type, path| path}
    end
    def source_folder
      Test.get_test_folders
    end

    PREPARE = ->() {
      Test.get_test_folders.each do |test_folder|
        FileUtils.rm_rf(test_folder)
      end
    }

    ############################################
    def create_sample_sources
      @css1 = Source.build(:name => 'css1.css', :type => SourceType::CSS)
      @css2 = Source.build(:name => 'css2.css', :type => SourceType::CSS)
      @css3 = Source.build(:name => 'css3.css', :type => SourceType::CSS)
      @layout1 = Source.build(:name => 'layout1', :type => SourceType::LAYOUT)
      @layout2 = Source.build(:name => 'layout2', :type => SourceType::LAYOUT)
      @layout3 = Source.build(:name => 'layout3', :type => SourceType::LAYOUT)
      @seo1 = Source.build(:name => 'seo1.css', :type => SourceType::SEO)
      @seo2 = Source.build(:name => 'seo2.css', :type => SourceType::SEO)
      @seo3 = Source.build(:name => 'seo3.css', :type => SourceType::SEO)
    end

    #  TESTS

    def test_reorganize_structure
      create_sample_sources
      @css2.attach_to(@layout2)
      @seo2.attach_to(@layout2)
      @layout2.attach_to(@layout1)
      layout2_id = @layout2.get_source_id
      layout3_id = @layout3.get_source_id

      @layout2 = Source.reorganize_by_ids(layout2_id, layout3_id)

      assert_true(@layout1.get_source_attaches == [])
      assert_equal(@layout2.get_source_target.get_source_filepath, @layout3.get_source_filepath)
      assert_equal(@layout2.get_source_filename, '1-tar-layout3-tar-layout2')
      assert_true(@layout3.get_source_attaches.size == 1)
    end

    ############################################
    Test.new.runner(PREPARE)
  end
end