require './../app/models/cms/source'
require './../app/models/cms/adapter'
require './../app/models/cms/source_type'
require './../config/initializers/public_constants'

module Tests
  class Test
    require_relative 'test_suite'
    include TestSuite
    def self.base_folder
      Cms::TEST_SOURCE_FOLDER
    end
    def base_folder
      Test.base_folder
    end

    PREPARE = ->() {
      FileUtils.rm_rf(Tests::Test.base_folder)
    }

    ############################################
    #TESTS:

    def test_failure
      assert_equal(true, false)
    end

    ############################################
    Test.new.runner(PREPARE)
  end
end