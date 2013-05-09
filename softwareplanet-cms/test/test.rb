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
      FileUtils.rm_rf(TEST_SOURCE_FOLDERS[SourceType::CSS])
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
      @seo1 = Source.build(:name => 'seo1', :type => SourceType::SEO)
      @seo2 = Source.build(:name => 'seo2', :type => SourceType::SEO)
      @seo3 = Source.build(:name => 'seo3', :type => SourceType::SEO)
      @seo4 = Source.build(:name => 'seo4', :type => SourceType::SEO)
      @seo5 = Source.build(:name => 'seo5', :type => SourceType::SEO)
      @setting1 = Source.build(:type => SourceType::SETTINGS, :name => 'setting1', :data => SourceSettings.default_settings.to_s)
      @setting2 = Source.build(:type => SourceType::SETTINGS, :name => 'setting2', :data => SourceSettings.default_settings.to_s)
      @setting3 = Source.build(:type => SourceType::SETTINGS, :name => 'setting3', :data => SourceSettings.default_settings.to_s)
      @setting4 = Source.build(:type => SourceType::SETTINGS, :name => 'setting4', :data => SourceSettings.default_settings.to_s)
      @setting5 = Source.build(:type => SourceType::SETTINGS, :name => 'setting5', :data => SourceSettings.default_settings.to_s)

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
      assert_equal(@layout3.get_source_attach(SourceType::LAYOUT).get_source_path, @layout1.get_source_path)
    end


    def test_update_dependencies_after_attach
      create_sample_sources
      @layout1.attach_to(@layout2)
      @layout2.attach_to(@layout3)
      assert_equal(@layout3.get_source_attach(SourceType::LAYOUT).get_source_attach(SourceType::LAYOUT).get_source_name, 'layout1')
    end

    def test_get_source_attaches
      create_sample_sources
      @css1.attach_to(@layout1)
      @seo1.attach_to(@layout1)
      source_attaches = @layout1.get_source_attaches
      assert_equal(source_attaches.size, 2)
    end

    def test_parse_settings_source
      create_sample_sources
      settings = SourceSettings.new.parse(@setting1)
      settings_in_array = settings.instance_variables
      assert_equal(settings_in_array.size, SETTINGS_DEFINITION[0].size)
      assert_equal(settings.publish, SETTINGS_DEFINITION[0][:publish])
      assert_equal(settings.display, SETTINGS_DEFINITION[0][:display])
    end

    #def test_get_data_from_settings
    #  create_sample_sources
    #  test_value = '0'
    #  settings = SourceSettings.new.parse(@setting1)
    #  settings.publish= test_value
    #  settings.display= test_value
    #  @setting1.set_data(settings.get_data)
    #  settings = SourceSettings.new.parse(@setting1)
    #  assert_equal(settings.publish, test_value)
    #  assert_equal(settings.display, test_value)
    #end
    #def test_get_source_settings
    #  create_sample_sources
    #  @seo1.attach_to(@layout1)
    #  @settings_count = Source.get_source_settings(@layout1.get_id).size
    #  assert_equal(@settings_count, SETTINGS_DEFINITION.size)
    #end

    #def test_rename_source_with_attaches
    #  layout = Source.build(:type =>Cms::SourceType::LAYOUT, :name => 'test')
    #  css = Source.build(:type => Cms::SourceType::CSS, :target => layout, :name => 'test')
    #  rename
    #end

    ############################################
    Test.new.runner(PREPARE)
  end
end