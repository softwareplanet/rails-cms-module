# Simple Test Suite.
# Simple Test Suite.
# How to use: open terminal. Go to test folder, and run `ruby active_file_test.rb`. Alternatively, run from your IDE.
require '../active_file/base'

class Material < ActiveFile::Base; end
class Diamond < ActiveFile::Base; end
class Photo < ActiveFile::Base; end
class ForeverAlone < ActiveFile::Base; end

Material.has_one :diamond
Diamond.belongs_to :material
Diamond.has_many :photos
Photo.belongs_to :diamond

class A  < ActiveFile::Base
  has_one :b
  has_many :c
end
class B  < ActiveFile::Base
  belongs_to :a
  has_many :c
end
class C  < ActiveFile::Base
  belongs_to :a
  belongs_to :b
end


module TestSuite
  require 'fileutils'
  def assert_true(assertion)
    raise "\n Assertion failed at: \n " unless assertion
  end
  def assert_equal(got_value, expected)
    raise "\n AssertEqual failed: Expected: #{expected}, got: #{got_value} \n " unless got_value === expected
  end
  def assert_raise_base
    begin
      yield
    rescue => raised; end
    raised
  end
  def assert_raise
    raised = assert_raise_base{yield}
    assert_true(raised != nil)
    p "..raised with <#{raised}>, assertion OK."
  end
  def assert_not_raise
    raised = assert_raise_base{yield}
    assert_true(raised == nil)
  end
  def prepare
    FileUtils.rm_rf(ActiveFile::Dependency::BASE_FOLDER)
  end
  def runner
    puts "-------------\n Starting at #{@start = Time.now}...\n\n"
    super_test_methods = self.class.instance_methods.select{|m| m.to_s.start_with?('super_test_') }
    test_methods = super_test_methods.any? ? super_test_methods : self.class.instance_methods.select{|m| m.to_s.start_with?('test_') }
    test_methods.each { |test| puts "Start #{test}.."; prepare; self.send(test) }
    puts "\n***\n#{test_methods.size} tests passed Successfully in #{Time.now - @start} seconds!\n***"
  end
end

module Tests
  class Test
    include TestSuite

    def base_folder
      ActiveFile::Dependency::BASE_FOLDER
    end

    def test_empty_constructor
      assert_not_raise{Diamond.new}
    end
    def test_arbitrary_attribute
      diamond = Diamond.new(name: 'Gem')
      assert_true(diamond.name == 'Gem')
    end
    def test_attributes_array
      photo1 = Photo.new(name: 'photo1')
      photo2 = Photo.new(name: 'photo2')
      diamond = Diamond.new(name: 'Gem', photos: [photo1, photo2])
      assert_true(diamond.photos.size == 2)
    end
    def test_get_file_path
      material = Material.new(name: 'Carbon')
      assert_equal(material.get_file_path, base_folder+'materials/Carbon')
    end
    def test_get_file_path_extension
      material = Material.new(name: 'Carbon.txt')
      assert_equal(material.get_file_path, base_folder+'materials/Carbon.txt')
    end
    def test_get_belongs_path
      material = Material.new(:name => 'Carbon')
      diamond = Diamond.new(:name => 'Gem', material: material)
      assert_equal(diamond.get_file_path, base_folder+'diamonds/Gem-tar-material-Carbon')
    end
    def test_get_belongs_path_extension
      material = Material.new(:name => 'Carbon.txt')
      diamond = Diamond.new(:name => 'Gem', material: material)
      assert_equal(diamond.get_file_path, base_folder+'diamonds/Gem-tar-material-Carbon-ext-txt')
    end
    def test_save_method
      material = Material.new(:name => 'Leonid.txt', :data => 'This is Spartaaaaa!')
      material.save
      assert_true(File.exists?(material.get_file_path))
    end
    def test_finder
      material = Material.new(:name => 'Leonid.txt')
      material.save
      search_result = Material.find('Leonid.txt')
      assert_equal(material, search_result)
    end
    def test_find_method
      Material.new(name: 'Carbon', data: 'File text data').save
      material = Material.find('Carbon')
      assert_true(material != nil)
      assert_equal(material.get_data, 'File text data')
    end
    def test_set_data_method
      material = Material.new(name: 'Carbon')
      material.set_data('File text data')
      assert_equal(material.get_data, 'File text data')
      material.save
      material = Material.find('Carbon')
      assert_true(material != nil)
      assert_equal(material.get_data, 'File text data')
    end
    def super_test_belongs_to
      material = Material.new(:name => 'Carbon')
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

  end
  # run all tests
  Test.new.runner
end