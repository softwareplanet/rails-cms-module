# RailsCMS Simple Test Suite
# Run in terminal `ruby active_file_test.rb`. Alternatively, debug from your IDE.
# To run only specific tests, add 'super_' before test name

require_relative 'base'

# Define test classes:
class Layout < ActiveFile::Base
  has_one :css
  has_one :seo_tag
end

class Content < ActiveFile::Base
  has_one :css
end

class Css < ActiveFile::Base
  belongs_to :layout
  belongs_to :content
  file_path "app/assets/stylesheets"
end

class SeoTag < ActiveFile::Base
  belongs_to :layout
end

class Gallery < ActiveFile::Base
  has_many :images
end

class Image < ActiveFile::Base
  belongs_to :gallery
end

module Tests
  class Test
    require_relative 'test_suite'
    include TestSuite

    def test_empty_constructor
      assert_not_raise{Layout.new}
    end

    def test_arbitrary_attribute
      layout = Layout.new(name: 'main')
      assert_true(layout.name == 'main')
    end

    def test_attributes_array
      img1 = Image.new(name: 'img1')
      img2 = Image.new(name: 'img2')
      layout = Layout.new(name: 'main', images: [img1, img2])
      assert_true(layout.images.size == 2)
    end

    def test_get_file_path
      layout = Layout.new(name: 'main')
      assert_equal(layout.get_file_path, base_folder+'layouts/main')
    end

    def test_get_file_path_extension
      layout = Layout.new(name: 'main.layout')
      assert_equal(layout.get_file_path, base_folder+'layouts/main.layout')
    end

    def test_get_belongs_path
      layout = Layout.new(:name => 'main')
      seo = SeoTag.new(:name => 'main-seo-tag', layout: layout)
      assert_equal(seo.get_file_path, base_folder+'seotags/main-seo-tag-tar-layout-main')
    end

    def test_get_belongs_path_extension
      layout = Layout.new(:name => 'main.txt')
      seo = SeoTag.new(:name => 'main-seo-tag.seo', layout: layout)
      assert_equal(seo.get_file_path, base_folder+'seotags/main-seo-tag-tar-layout-main-ext-txt.seo')
    end

    def test_save_method
      layout = Layout.new(:name => 'Leonid.txt', :data => 'This is Sparta!')
      layout.save
      assert_true(File.exists?(layout.get_file_path))
    end

    def test_finder
      layout = Layout.new(:name => 'Leonid.txt')
      layout.save
      search_result = Layout.find('Leonid.txt')
      assert_equal(layout, search_result)
    end

    def test_find_method
      Layout.new(name: 'Carbon', data: 'Layout data').save
      layout = Layout.find('Carbon')
      assert_true(layout != nil)
      assert_equal(layout.get_data, 'Layout data')
    end

    def super_test_set_data_method
      layout = Layout.new(name: 'Carbon')
      layout.set_data('File text data')
      assert_equal(material.get_data, 'File text data')
      material.save
      material = Material.find('Carbon')
      assert_true(material != nil)
      assert_equal(material.get_data, 'File text data')
    end
    def test_belongs_to
      material = Layout.new(:name => 'Carbon')
      diamond = Diamond.new(:material => material, :name => 'Gem')
      diamond.save
      new_diamond = Diamond.find('Gem')
      assert_equal(new_diamond.material, material)
    end

    #def super_test_belongs_to_dependency
    #  material = Material.new
    #  diamond = Diamond.new(:material => material)
    #  assert_true(diamond.material == material)
    #end
    def test_has_one_dependency
      diamond = Diamond.new(name:'Gem')
      material = Material.new(name:'Carbon', :diamond => diamond)

      assert_true(material.diamond == diamond)
    end
    def test_second
      assert_true(true)
    end

    def self.base_folder
      ActiveFile::BASE_FOLDER
    end

    def base_folder
      Test.base_folder
    end
  end


  PREPARE = ->() {
    FileUtils.rm_rf(Tests::Test.base_folder)
  }

  # run all tests
  Test.new.runner(PREPARE)
end