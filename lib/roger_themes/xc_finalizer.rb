require "roger/release"

module RogerThemes
  class XcFinalizer < Roger::Release::Finalizers::Base
    self.name = :xc_finalizer

    def default_options
      {
        :prefix => nil,
        :zip => "zip",
        :sources => ['rel', 'js'],
        :source_path => release.build_path + "themes/*",
        :target_path => release.build_path + "themes/zips"
      }
    end

    # XC finalizer finalizes designzips.
    #
    # @param [Hash] options Options hash
    # @option options [String, nil] :prefix (nil) The name to prefix the zipfile with (before version)
    # @option options [String] :zip ("zip") The ZIP command to use
    # @option options [String, Pathname] :source_path (release.build_path + "themes/*") The paths to zip
    # @option options [String, Pathname] :target_path (release.build_path + "themes/zips") The path to the zips
    def perform()
      dirs = Dir.glob(options[:source_path].to_s)

      zipdir = Pathname.new(options[:target_path])
      FileUtils.mkdir_p(zipdir) unless zipdir.exist?

      dirs.each do |dir|
        # Do not generate zip of intermediary zips
        next if dir.include?(".")

        name = [options[:prefix], File.basename(dir), release.scm.version].compact.join("-")
        path = Pathname.new(dir)

        begin
          `#{options[:zip]} -v`
        rescue Errno::ENOENT
          raise RuntimeError, "Could not find zip in #{options[:zip].inspect}"
        end

        ::Dir.chdir(path) do
          zipfiles = options[:sources].map { |a| Shellwords.escape(a) }.join(' ')
          `#{options[:zip]} -r -9 "#{zipdir + name}.zip" #{zipfiles}`
        end

        release.log(self, "Creating zip for custom #{name}")

      end
    end
  end
end
