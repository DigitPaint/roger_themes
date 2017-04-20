require "test_helper"
require "rack/mock"
require "roger/testing/mock_project"

require "./lib/roger_themes/middleware"

class MockApp
  attr_reader :call_stack
  attr_writer :return_value

  def initialize()
    @call_stack = []

    @return_value = [200, {}, ["YAM"]]
  end

  def call(env)
    @call_stack.push env.dup
    @return_value
  end
end


module RogerThemes
  class TestMiddleware < ::Test::Unit::TestCase

    def setup
      @app =  MockApp.new # Yet another middleware
      @middleware = Middleware.new @app

      # Inject mock project
      @middleware.project = Roger::Testing::MockProject.new("test/fixture")

      @request = Rack::MockRequest.new(@middleware)
    end

    def teardown
      @middleware.project.destroy
    end

    def test_middleware_can_be_called
      assert(@middleware.respond_to?(:call))
    end

    def test_doesnt_touch_other_requests
      assert_equal @request.get("/my.js").body, "YAM"
    end

    # Theme links work by means of rewriting the path info i.e.
    # to render and setting the env[site_theme] var
    def test_main_theme_url
      @request.get("/themes/my-awesome-theme/theme/elements/index.html")
      assert_equal @app.call_stack.length, 1
      assert_equal @app.call_stack[0]["MAIN_THEME"].name, "my-awesome-theme"
      assert_equal @app.call_stack[0]["PATH_INFO"], "elements/index.html"
    end

    def test_sub_theme_url
      @request.get("/themes/my-awesome-theme.my-sub-theme/theme/elements/index.html")
      assert_equal @app.call_stack.length, 1
      assert_equal @app.call_stack[0]["MAIN_THEME"].name, "my-awesome-theme"
      assert_equal @app.call_stack[0]["SUB_THEME"].name, "my-sub-theme"
      assert_equal @app.call_stack[0]["PATH_INFO"], "elements/index.html"
    end

    def test_local_main_theme_url
      @request.get("/themes/my-awesome-theme/index.html")
      assert_equal @app.call_stack.length, 1
      assert_equal @app.call_stack[0]["PATH_INFO"], "/themes/my-awesome-theme/index.html"
    end

    def test_shared_resources
      # Shared resource will update the PATH_INFO to render a shared image or font
      @app.return_value = [404, {}, ["YAM"]]
      @request.get("/themes/my-awesome-theme/images/fancy.png")
      assert_equal @app.call_stack.length, 2
      assert_equal @app.call_stack[1]["PATH_INFO"], "/images/fancy.png"
    end

    def test_shared_resources_when_not_modified_is_returned
      @app.return_value = [304, {}, ["YAM"]]
      @request.get("/themes/my-awesome-theme/images/fancy.png")
      assert_equal @app.call_stack.length, 1
      assert_equal @app.call_stack[0]["PATH_INFO"], "/themes/my-awesome-theme/images/fancy.png"
    end


  end
end
