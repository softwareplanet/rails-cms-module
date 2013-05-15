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
      @seo1 = Source.build(:name => 'seo1', :type => SourceType::SEO, :data => SourceSEO.default_seo.to_s)
      @seo2 = Source.build(:name => 'seo2', :type => SourceType::SEO, :data => SourceSEO.default_seo.to_s)
      @seo3 = Source.build(:name => 'seo3', :type => SourceType::SEO, :data => SourceSEO.default_seo.to_s)
      @seo4 = Source.build(:name => 'seo4', :type => SourceType::SEO, :data => SourceSEO.default_seo.to_s)
      @seo5 = Source.build(:name => 'seo5', :type => SourceType::SEO, :data => SourceSEO.default_seo.to_s)
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

    def test_parse_source_settings
      create_sample_sources
      settings = SourceSettings.new.read_source_settings(@setting1)
      settings_in_array = settings.instance_variables
      assert_equal(settings_in_array.size, SETTINGS_DEFINITION[0].size)
      assert_equal(settings.publish, SETTINGS_DEFINITION[0]['publish'])
      assert_equal(settings.display, SETTINGS_DEFINITION[0]['display'])
    end

    def test_get_data_from_parsed_settings
      create_sample_sources
      parsed_settings = SourceSettings.new.read_source_settings(@setting1)
      data = parsed_settings.get_data_yml
      assert_equal(data, SETTINGS_DEFINITION[0].to_yaml)
    end

    def test_set_data_to_settings
      create_sample_sources
      test_value = '0'
      parsed_settings = SourceSettings.new.read_source_settings(@setting1)
      parsed_settings.publish= test_value
      parsed_settings.display= test_value
      @setting1.set_data(parsed_settings.get_data_yml)
      parsed_settings = SourceSettings.new.read_source_settings(@setting1)
      assert_equal(parsed_settings.publish, test_value)
      assert_equal(parsed_settings.display, test_value)
    end

    def test_get_source_settings
      create_sample_sources
      @setting1.attach_to(@layout1)
      source_settings = Source.get_source_settings(@layout1.get_id)
      source_settings.instance_variables.each do |key|
          assert_equal(source_settings.instance_variable_get(key), SETTINGS_DEFINITION[0][key.to_s.delete("@")])
      end
    end

    def test_rename_source_with_attaches
      create_sample_sources
      name_prefix = 'test_'
      @css1.attach_to(@layout1)
      @seo1.attach_to(@layout1)
      @setting1.attach_to(@layout1)
      new_name = name_prefix + @layout1.get_source_name
      @layout1.rename_source(new_name)
      @layout1.get_source_attaches.each do |attach|
        assert_equal(attach.get_source_target.get_source_id, @layout1.get_source_id)
      end
      assert_true(@layout1.get_source_name.start_with?(name_prefix))
    end

    def test_create_page
      params ={
          :name => 'test_name',
          :publish => 'on',
          :display => nil,
          :title => 'test title',
          :keywords => 'test keywords',
          :description => 'test description'
      }
      assert_not_raise do
        Source.create_page(params)
      end
    end

    def load_check_when_creating_resources
      #in console last result is time=15.893040497 seconds! for all sources * 10 000
      time = Time.now
      source_types = SourceType::all
      for number in 1..10000
        source_types.map do |k,v|
          Source.build(:name => k.to_s + number.to_s, :type => v)
        end
      end
      result = Time.now - time
      puts "result is time=#{result} seconds!"
    end

    ##########@seo_tags.get_data##################################
    Test.new.runner(PREPARE)
  end
end