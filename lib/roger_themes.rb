require "roger_themes/version"

require "fileutils"
include FileUtils

module RogerThemes

  # The path within the project.html_path
  def self.themes_path=(path)
    @themes_path = path.to_s.sub(/\A\//, "")
  end

  def self.themes_path
    @themes_path || "themes"
  end

end

require "roger_themes/asset_writer"
require "roger_themes/manifest"
require "roger_themes/asset"
require "roger_themes/theme"
require "roger_themes/middleware"
require "roger_themes/processor"
require "roger_themes/xc_finalizer"
