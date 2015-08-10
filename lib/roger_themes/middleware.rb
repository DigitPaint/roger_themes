require File.dirname(__FILE__) + "/shared_folders"

module RogerThemes
  class Middleware
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
      path = ::Rack::Utils.unescape(env["PATH_INFO"])
      r = /\A\/themes\/([^\/]+)\/theme\//
      if theme = path[r,1]
        orig_path = env["PATH_INFO"].dup
        env["SITE_THEME"] = theme
        env["PATH_INFO"].sub!(r,"")
      else
        # Set default theme
        env["SITE_THEME"] = @options[:default_theme]
      end

      ret = @app.call(env)

      # Fallback for shared images
      unless ret[0] == 200

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
