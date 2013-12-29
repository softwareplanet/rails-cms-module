require_relative 'tiny_source'

module Cms
  class Test
    require_relative 'test_suite'
    include TestSuite
    PREPARE = ->() {
      
    }

    ############################################
    #TESTS:

    def test_accept_true
      assert_true Source.new.accept_true
    end

    ############################################
    Test.new.runner(PREPARE)
  end
end