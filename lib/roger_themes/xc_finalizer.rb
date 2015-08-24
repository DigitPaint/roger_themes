require "roger/release"

module RogerThemes
  class XcFinalizer < Roger::Release::Finalizers::Base
    attr_reader :release

    # XC finalizer finalizes designzips.
    #
    # @param [Release] release
    # @param [Hash] options Options hash
    # @option options [String, nil] :prefix (nil) The name to prefix the zipfile with (before version)
    # @option options [String] :zip ("zip") The ZIP command to use
    # @option options [String] :source_path (release.build_path + "themes/*") The paths to zip
    # @option options [String] :target_path (release.build_path + "themes/zips") The path to the zips
    def call(release, options = {})
      options = {
        :prefix => nil,
        :zip => "zip",
        :source_path => release.build_path + "themes/*",
        :target_path => release.build_path + "themes/zips"
      }.update(options)

      dirs = Dir.glob(options[:source_path].to_s)

      zipdir = Pathname.new(options[:target_path])
      FileUtils.mkdir_p(zipdir) unless zipdir.exist?

      dirs.each do |dir|
        name = [options[:prefix], File.basename(dir), release.scm.version].compact.join("-")
        path = Pathname.new(dir)

        begin
          `#{options[:zip]} -v`
        rescue Errno::ENOENT
          raise RuntimeError, "Could not find zip in #{options[:zip].inspect}"
        end

        ::Dir.chdir(path) do
          `#{options[:zip]} -r -9 "#{zipdir + name}.zip" rel js`
        end

        release.log(self, "Creating zip for custom #{name}")

      end
    end
  end
end
