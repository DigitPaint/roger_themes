require "./lib/roger_themes/processor"
require "roger/testing/mock_release"

require "test_helper"

module RogerThemes
  class TestProcessor < ::Test::Unit::TestCase
    def setup
      @release = Roger::Testing::MockRelease.new
      @release.project.construct.directory "build" do |dir|
        dir.directory "themes/default/"
      end

      @processor = Processor.new
    end

    def teardown
      @release.destroy
    end

    def test_processor_can_be_called
      assert(@processor.respond_to?(:call))
      assert(@processor.respond_to?(:perform))
    end

    def test_processor_copies_shared_folders
      @release.project.construct.directory "build" do |dir|
        dir.file "fonts/abc/info.txt", "Default font"
      end

      @processor.call(@release)

      shared_font = read_file_in_build("themes/default/fonts/abc/info.txt")
      assert shared_font.include?("Default font")
    end

    def test_processor_copies_shared_folders_with_local_folder
      @release.project.construct.directory "build" do |dir|
        dir.file "themes/default/fonts/def/info.txt", "Custom theme font"
        dir.file "fonts/abc/info.txt", "Default font"
      end

      @processor.call(@release)

      localised_font = read_file_in_build("themes/default/fonts/def/info.txt")
      shared_font = read_file_in_build("themes/default/fonts/abc/info.txt")
      assert localised_font.include?("Custom theme font")
      assert shared_font.include?("Default font")
    end

    protected

    def read_file_in_build(path)
      full_path = (@release.build_path + path).to_s
      assert File.exist?(full_path)
      File.read(full_path)
    end
  end
end
