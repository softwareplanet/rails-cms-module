# Simple Test Suite, for specially developed for RailsCMS

module TestSuite
  require 'fileutils'

  def assert_true(assertion)
    raise "\n Assertion failed at: \n " if assertion == false
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

  def runner(prepare_method)
    puts "-------------\n Starting at #{@start = Time.now}...\n\n"
    super_test_methods = self.class.instance_methods.select{|m| m.to_s.start_with?("super_test_") }
    test_methods = super_test_methods.any? ? super_test_methods : self.class.instance_methods.select{|m| m.to_s.start_with?("test_") }
    test_methods.each { |test|
      puts "Start #{test}..";

      prepare_method.()

      self.send(test)
    }
    puts "\n***\n#{test_methods.size} tests passed Successfully in #{Time.now - @start} seconds!\n***"
  end
end