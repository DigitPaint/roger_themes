require 'yaml'

module RogerThemes
  class Manifest

    DEFAULTS = {
      title: nil,
      type: "main",
      mains: nil,
      shared_folders: nil,
      shared_templates: true,
      assets: []
    }

    def initialize(theme)
      manifest_path = theme.path + "manifest.yml"

      @data = {}.update(DEFAULTS)

      if File.exist?(manifest_path)
        data = YAML.load_file(manifest_path)
        data.each do |k,v|
          @data[k.to_sym] = v
        end
      end

      # Make sure we have a title
      @data[:title] ||= theme.name
    end

    def [](name)
      @data[name]
    end

  end
end
