require "test_helper"
require "./lib/roger_themes/shared_folders"

require "rack/mock"

module RogerThemes
  class TestSharedFolders < ::Test::Unit::TestCase
    def setup
      @shared_folders = SharedFolders.new(["images", "fonts"])
    end

    def test_simple_case_with_array
      shared_path = @shared_folders.local_to_shared_path("/themes/default/fonts/")
      assert_equal "/fonts/", shared_path
    end

    def test_with_hash
      @shared_folders = SharedFolders.new("fonts" => "rel/fonts",
                                          "images" => "rel/images")

      shared_path = @shared_folders.local_to_shared_path("/themes/default/rel/fonts/")
      assert_equal "/fonts/", shared_path
    end

    def test_returns_false_when_no_shared_folder
      shared_path = @shared_folders.local_to_shared_path("/themes/default/not_found/")
      assert !shared_path
    end
  end
end
