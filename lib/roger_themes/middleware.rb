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
      @shared_folders = SharedFolders.new(@options[:shared_folders])
    end

    def call(env)
      project = env["roger.project"] || self.project # self.project is for tests.
      themes_path = project.html_path + RogerThemes.themes_path

      path = ::Rack::Utils.unescape(env["PATH_INFO"])
      r = /\A\/#{Regexp.escape(RogerThemes.themes_path)}\/([^\/]+)\/theme\//

      env["SUB_THEME"] = nil

      if theme = path[r,1]
        main_theme, sub_theme = theme.split(".", 2)
        orig_path = env["PATH_INFO"].dup
        env["MAIN_THEME"] = Theme.new(main_theme, themes_path)
        env["SUB_THEME"] = Theme.new(sub_theme, themes_path) if sub_theme
        env["PATH_INFO"].sub!(r,"")
      else
        # Set default theme
        env["MAIN_THEME"] = Theme.new(@options[:default_theme], themes_path)
      end

      ret = @app.call(env)

      # Fallback for shared images
      if ret[0] == 404

        shared_path = @shared_folders.local_to_shared_path(path)

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
