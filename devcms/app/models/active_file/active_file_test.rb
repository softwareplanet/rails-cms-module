# ActiveFile Test Suite.
# How to run:
# Open terminal. Navigate to test folder, and run `ruby active_file_test.rb`

# Test classes:______________

require '../active_file/base'
include ActiveFile

  class Material < ActiveFile::Base
    #has_one :diamond
  end
  class Diamond < ActiveFile::Base
    #belongs_to :material
    #has_many :images
  end
  class Image < ActiveFile::Base
    #belongs_to :diamond
  end
  Material.has_one :diamond
  Diamond.belongs_to :material
  Diamond.has_many :images
  Image.belongs_to :diamond



module ActiveFileTest
  require 'fileutils'
  require '../active_file/base'
  include ActiveFile

  # Test suite:______________
  class Test
    def assert_true(assertion)
      if assertion == false
        raise "\n\nAssertion failed at:\n\n#{caller}"
      end
    end
    def prepare
      FileUtils.rm_rf('data_source')
    end
    def runner
      test_methods = Test.instance_methods.select{|m|
        m.to_s.start_with?("test_")
      }
      puts "-------------\n\nStarting at #{Time.now}...\n\n"
      test_methods.each do |test|
        puts "Start #{test}.."
        prepare
        self.send(test)
      end
      puts "\n***\n#{test_methods.size} tests passed Successfully!\n***"
    end


    def test_first
      material = "xmaterial"
      d = Diamond.new("Cullinan", :parent => material)
      #d.data = 'The Cullinan diamond is the largest gem-quality diamond ever found, at 3106.75 carat (603.35 g, 1.37 lb) rough weight.[1] About 10.5 cm (4.1 inches) long in its largest dimension, it was found January 26, 1905, in the Premier No. 2 mine, near Pretoria, South Africa.'
      #d.save!
      #assert_true(File.exists?('/data_source/diamond/Cullinan'))
    end

    def test_second
      assert_true(true)
    end
  end


  test = Test.new
  test.runner
end