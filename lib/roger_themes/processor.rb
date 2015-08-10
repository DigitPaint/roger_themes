require "roger/release/processors/mockup"

module RogerThemes
  class Processor < Roger::Release::Processors::Base
    def initialize(options = {})

      defaults = {
        default_theme: 'default',
        excludes: [
          /\A_doc\/.*/,
          /\Athemes\/.*/,
          "index.html"
        ],
        shared_folders: ["images", "fonts"]
      }

      @options = defaults.update(options)
    end

    def call(release, options)
      @options = @options.dup.update(options)

      files_glob = "**/*{.html,.html.erb}"

      themes = []

      Dir.chdir(release.build_path) do
        Dir.chdir("themes") do
          themes = Dir.glob("*").select{|d| File.directory?(d) }.map{|t| [t, Pathname.new("themes/#{t}/theme")] }
        end

        # Get files from html path
        files = Dir.glob("../html/#{files_glob}").map{ |f| f.sub("../html/", "") }
        files.reject!{|c| @options[:excludes].detect{|e| e.match(c) } }

        release.debug self, "Copying theme files #{files.inspect}"

        themes.each do |theme, theme_dir|
          mkdir_p theme_dir

          files.each do |file|
            mkdir_p theme_dir + File.dirname(file)
            cp release.project.html_path + file, theme_dir + file
          end
        end
      end

      # Run mockup for each theme
      themes.each do |theme, theme_dir|
        match_glob = theme_dir + files_glob

        mockup_processor = Roger::Release::Processors::Mockup.new({
          match: [match_glob],
          env: {
            "SITE_THEME" => theme,
            "MOCKUP_PROJECT" => release.project
          }
        })
        mockup_processor.call(release)

        # cp html/images and html/fonts => html/themes/**/images && html/themes/**/fonts
        # if not in target dir
        # well conceptual not complete, doing so would required scanning all HTML and
        # CSS I suppose.
        #
        # This means that it could be possible to get images that are not used within the
        # zip, since these are not requried in css it wouln't cause any problems thou
        # the zip size does increase
        #
        # Behavior must be simialir to the rewrite in processor
        release.debug self, "Starting assets copy for #{@options[:shared_folders]}"
        shared_folders = SharedFolders.new(@options[:shared_folders])

        Dir.chdir(release.build_path + "themes/#{theme}") do
          release.debug self, "Copying assets for #{theme}"
          shared_folders.folders.each do |copy_from, copy_to|
            cp_r release.build_path + copy_from, copy_to
          end
        end
      end
    end
  end
end
