# gem install "minitest"

module ActiveFile

  require 'minitest/autorun'
  #include ActiveFile
  #require 'cms/app/models/active_file/base.rb'

  puts Dir.pwd

  TEST_FILES_FOLDER = "/testfiles" # TODO provide tests with separate folder
                                   # TODO cleanup test folder before testing

  class File < ActiveFile::Base
  end

  class AdapterTest < MiniTest::Unit::TestCase
    def setup
      @file = File.new
    end

    def test_on_save
      assert_raises(ArgumentError) { @file.save! } # Name can not be blank:
      @file.name = "testee"
      assert_equal(true, @file.new_record?)
      assert_equal(true, @file.save!)
      assert_equal(false, @file.new_record?)
      assert_equal(true, ::File.exists?(@file.get_source_path))
      @file.data = "some data"
      @file.save!
    end

  end

end