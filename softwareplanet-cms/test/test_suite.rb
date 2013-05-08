# Simple Test Suite, developed for 'SoftwarePlanet CMS'
# Usage:
# Create tests runner class and add this suite for testing.
# Create test methods, by adding 'test_' prefix before file name
# Then, run test class in terminal with command `ruby test-file.rb`. Alternatively, debug file from your IDE.
# To run only specific tests, add 'super_' before test name.
# Example:

#  module Tests
#    class Test
#      require_relative 'test_suite'
#      include TestSuite
#
#      def test_none
#        puts 'Define your tests methods by adding test_ prefix to method name'
#      end
#
#      def test_assert
#        assert_true(true)
#      end
#
#      def test_equal
#        assert_equal('actual', 'expected')
#      end
#
#      def test_raise
#        assert_raise{1/0}
#      end
#
#      def test_not_raise
#        assert_not_raise{0/1}
#      end
#
#      def super_test_run_only_me
#        puts 'all tests, started with super_test_, will be executed excluding all simple tests, started with test_'
#      end
#
#   end
#  end
#
#  ---------------------------
#  # you can define before_filter method, and pass it to test suite runner
#  PREPARE = ->() {
#    FileUtils.rm_rf('logs')
#  }
#
#  Test.new.runner(PREPARE)
#
#end
##


module TestSuite
  require 'fileutils'

  def assert_true(assertion)
    raise "\n Assert true failed with: #{assertion} is not true. \n " if assertion == false
  end

  def assert_equal(got_value, expected)
    raise "\n Assert equal failed: Expected #{expected}, got: #{got_value} \n " unless got_value == expected
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

  def prepare;

  end

  def runner(prepare_method=nil)
    puts "-------------\n Starting at #{@start = Time.now}...\n\n"
    super_test_methods = self.class.instance_methods.select{|m| m.to_s.start_with?("super_test_") }
    test_methods = super_test_methods.any? ? super_test_methods : self.class.instance_methods.select{|m| m.to_s.start_with?("test_") }
    test_methods.each { |test|
      puts "Start #{test}..";

      prepare_method.() unless prepare_method.nil?

      self.send(test)
    }
    puts "\n***\n#{test_methods.size} tests passed Successfully in #{Time.now - @start} seconds!\n***"
  end
end