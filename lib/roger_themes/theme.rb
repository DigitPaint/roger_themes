module RogerThemes
  class Theme
    attr_reader :path, :name, :manifest

    # Get all themes, will cache the results for a themesepath
    def self.all(themes_path, refresh = false)
      @_themes ||= {}

      if @_themes[themes_path] && !refresh
        return @_themes[themes_path]
      end

      @_themes[themes_path] = Dir.glob(themes_path + "*").select{|d| File.directory?(d) }.map do |path|
        name = path.sub(/\A#{Regexp.escape(themes_path.to_s)}/, "")
        Theme.new(name, themes_path)
      end
    end

    def self.sub_themes_for(main_theme_name, themes_path)
      all(themes_path).select{|theme| theme.type == "sub" && theme.compatible_with_main?(main_theme_name) }

    end

    def self.main_themes(themes_path)
      all(themes_path).select{|theme| theme.type == "main" }
    end

    def self.sub_themes(themes_path)
      all(themes_path).select{|theme| theme.type == "sub" }
    end

    def initialize(name, themes_path)
      @name = name.to_s.sub(/\A\//, "")
      @themes_path = themes_path
      @path = themes_path + @name
      @manifest = Manifest.new(self)
    end

    def title
      manifest[:title]
    end

    def type
      manifest[:type]
    end

    def mains
      manifest[:mains]
    end

    def assets
      return [] unless manifest[:assets]
      return @assets if @assets

      @assets = manifest[:assets].map {|asset_data| Asset.new(asset_data, self) }
    end

    # Wether or not we take the toplevel templates
    # and render them as our own.
    def shared_templates
      manifest[:shared_templates]
    end

    def sub_themes
      self.class.sub_themes_for(name, @themes_path)
    end

    def url
      "/" + RogerThemes.themes_path + "/" + name
    end

    # The path where the templates for this theme will reside
    def html_path
      self.path + "theme"
    end

    def html_path_in_main(main_theme_name)
      path_in_main(main_theme_name) + "theme"
    end

    def path_in_main(main_theme_name)
      @themes_path + [main_theme_name, name].join(".")
    end

    def compatible_with_main?(main_theme_name)
      return false unless self.mains.kind_of?(Array)

      mains.include?(main_theme_name)
    end
  end
end
