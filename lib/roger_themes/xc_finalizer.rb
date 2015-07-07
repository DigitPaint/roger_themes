module RogerThemes
  class XcFinalizer < Roger::Release::Finalizers::Base
    attr_reader :release

    def call(release, options = {})
      dirs = Dir.glob((release.build_path + "themes/*").to_s)

      options = {
        :prefix => "html",
        :zip => "zip"
      }.update(options)

      releasename = [(options[:prefix] || "html"), release.scm.version].join("-")

      zipdir = release.build_path + "themes/zips"
      FileUtils.mkdir_p(zipdir) unless zipdir.exist?

      dirs.each do |dir|
        name = File.basename(dir)
        path = Pathname.new(dir)

        begin
          `#{options[:zip]} -v`
        rescue Errno::ENOENT
          raise RuntimeError, "Could not find zip in #{options[:zip].inspect}"
        end

        ::Dir.chdir(path) do
          `#{options[:zip]} -r -9 "#{zipdir + name}-#{release.scm.version}.zip" rel js`
        end

        release.log(self, "Creating zip for custom #{name}")

      end
    end
  end
end
