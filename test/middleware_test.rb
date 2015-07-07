require "test_helper"
require "./lib/roger_themes/middleware"

require "rack/mock"

module RogerThemes
  class TestMiddleware < ::Test::Unit::TestCase

    def setup
      @app =  proc { [200, {}, ["YAM"]] } # Yet another middleware
      @middleware = Middleware.new @app

      @request = Rack::MockRequest.new(@middleware)
    end

    def test_middleware_can_be_called
      assert(@middleware.respond_to?(:call))
    end

    def test_doesnt_touch_other_requests
      assert_equal @request.get("/my.js").body, "YAM"
    end

  end
end
