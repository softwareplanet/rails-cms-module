# Simple Test Suite.
# How to use: open terminal. Go to test folder, and run `ruby active_file_test.rb`. Alternatively, run from your IDE.
require '../active_file/base'
require 'minitest/unit'
class Material < ActiveFile::Base; end
class Diamond < ActiveFile::Base; end
class Photo < ActiveFile::Base; end
class ForeverAlone < ActiveFile::Base; end

Material.has_one :diamond
Diamond.belongs_to :material
Diamond.has_many :photos
Photo.belongs_to :diamond

module TestSuite
  require 'fileutils'
  def assert_true(assertion);
    raise "\n Assertion failed at: \n " if assertion == false
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
  def prepare; FileUtils.rm_rf('data_source'); end
  def runner
    puts "-------------\n Starting at #{@start = Time.now}...\n\n"
    super_test_methods = self.class.instance_methods.select{|m| m.to_s.start_with?("super_test_") }
    test_methods = super_test_methods.any? ? super_test_methods : self.class.instance_methods.select{|m| m.to_s.start_with?("test_") }
    test_methods.each { |test| puts "Start #{test}.."; prepare; self.send(test) }
    puts "\n***\n#{test_methods.size} tests passed Successfully in #{Time.now - @start} seconds!\n***"
  end
end

module Tests
  class Test
    include TestSuite

    def test_constructor_with_empty_name_should_raise
      assert_raise{Diamond.new('')}
    end
    def test_constructor_with_correct_string_name_should_not_raise
      assert_not_raise{Diamond.new('Gem')}
    end
    def test_constructor_with_correct_hash_name_should_not_raise
      assert_not_raise{Diamond.new(:name => 'Gem')}
    end
    def super_test_dependency
      material = Material.new('Carbon')
      diamond = Diamond.new('Gem', :material => material)
      assert_true(diamond.material == material)
    end
    def test_second
      assert_true(true)
    end

  end
  # run all tests
  Test.new.runner
end