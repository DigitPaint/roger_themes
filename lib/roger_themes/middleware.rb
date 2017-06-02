require File.dirname(__FILE__) + "/shared_folders"

module RogerThemes
  class Middleware
    attr_accessor :project

    def initialize(app, options = {})
      @app = app

      defaults = {
        default_theme: "default",
        shared_folders: ["images", "fonts"]
      }

      @options = defaults.update(options)
    end

    def call(env)
      project = env["roger.project"] || self.project # self.project is for tests.
      themes_path = project.html_path + RogerThemes.themes_path

      path = ::Rack::Utils.unescape(env["PATH_INFO"])

      # Regexp to match the theme url
      theme_url_regex = /\A\/#{Regexp.escape(RogerThemes.themes_path)}\/([^\/]+)\//
      shared_url_regex = Regexp.new(theme_url_regex.to_s + "theme\/")

      env["SUB_THEME"] = nil

      # Set the theme ENV paramaters
      if theme = path[theme_url_regex,1]
        main_theme, sub_theme = theme.split(".", 2)
        orig_path = env["PATH_INFO"].dup
        env["MAIN_THEME"] = Theme.new(main_theme, themes_path)
        env["SUB_THEME"] = Theme.new(sub_theme, themes_path) if sub_theme
      else
        # Set default theme
        env["MAIN_THEME"] = Theme.new(@options[:default_theme], themes_path)
      end

      # See if we have to render shared paths on /THEMES_PATH/THEME_NAME/theme/*
      if env["MAIN_THEME"].shared_templates && shared_url_regex.match(path)
        env["PATH_INFO"].sub!(shared_url_regex,"")
      end

      ret = @app.call(env)

      # Fallback for shared images
      if ret[0] == 404
        shared_folders = SharedFolders.new(env["MAIN_THEME"].shared_folders || @options[:shared_folders])

        shared_path = shared_folders.local_to_shared_path(path)

        if shared_path
          # Store so we can restore later
          orig_path = env["PATH_INFO"].dup
          env["PATH_INFO"] = shared_path
        end

        ret = @app.call(env)

        # Restore path so we are nice with everybody else
        env["PATH_INFO"] = orig_path
      end

      ret
    end
  end
end
