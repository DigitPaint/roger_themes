module RogerThemes
  class Asset
    attr_reader :theme, :data

    def initialize(data, theme)
      @data = {}
      update(data)
      @theme = theme
    end

    def update(data)
      @data.update(data)
    end

    def initialize_copy(source)
      @data = @data.dup
    end

    # Relative path within theme
    def path
      @data["path"].to_s
    end

    def full_path
      theme.path + path
    end

    def url
      [theme.url.sub(/\/\Z/, ''), path.sub(/\A\//, '')].join("/")
    end

    def location
      @data["location"].to_s
    end

    def type
      @data["type"].to_s
    end

    def attributes
      @data["attributes"] || {}
    end
  end
end
