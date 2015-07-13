# require rack utils

module RogerThemes
  class Middleware
    def initialize(app, options = {})
      @app = app

      defaults = {
        default_theme: 'default'
      }

      @options = defaults.update(options)
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
        r = /\A\/themes\/([^\/]+)\/rel\/images\//
        if asset = path[r, 1]
          orig_path = env["PATH_INFO"].dup
          env["PATH_INFO"].sub!(r, "/images/")
        end

        r = /\A\/themes\/([^\/]+)\/rel\/fonts\//
        if asset = path[r, 1]
          orig_path = env["PATH_INFO"].dup
          env["PATH_INFO"].sub!(r, "/fonts/")
        end

        ret = @app.call(env)

        # Restore path so we are nice with everybody else
        env["PATH_INFO"] = orig_path
      end

      ret
    end
  end
end
