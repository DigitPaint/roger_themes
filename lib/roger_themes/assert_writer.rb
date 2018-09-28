module RogerThemes::ViewHelper
  def self.asset_writer=(klass)
    @aw = klass
  end

  def self.asset_writer_class
    @aw || AssetWriter
  end

  def asset_writer
    path = env["roger.project"].mode == :release ? env["roger.project"].release.build_path : env["roger.project"].html_path
    @_asset_writer ||= ThemePlugin.asset_writer_class.new(main_theme, sub_theme, path)
  end

  # Will take sub and main theme and write out all assets
  def theme_assets_for_location(location)
    asset_writer.render(location, env)
  end

  def main_theme
    return env["MAIN_THEME"] if env["MAIN_THEME"]

    base_path = env['roger.project'].mode == :release ? env["roger.project"].release.build_path : env['roger.project'].html_path
    RogerThemes::Theme.new('default', base_path + RogerThemes.themes_path)
  end

  def sub_theme
    env["SUB_THEME"]
  end

  # Helper class for rendering all kinds of asset types
  class AssetWriter
    def initialize(main, sub = nil, html_path = nil)
      @main = main
      @sub = sub
      @html_path = html_path
    end

    def assets
      return @assets if @assets
      @assets = []
      @assets += @main.assets if @main.assets
      @assets += @sub.assets if @sub && @sub.assets
      @assets
    end

    def assets_for_location(location)
      assets.select{|a| a.location == location }
    end

    def render(location, env = {})
      assets_for_location(location).map do |asset|
        method_name = :"render_#{asset.type}"

        next unless self.respond_to?(method_name)

        self.send(method_name, asset, env)
      end.join("\n")
    end

    def tag(name, attr = {}, &block)
      doc = Nokogiri::HTML::DocumentFragment.parse ""

      builder = Nokogiri::HTML::Builder.with(doc) do |xml|
        if block_given?
          xml.method_missing(name, attr) do
            yield(xml)
          end
        else
          xml.method_missing(name, attr)
        end
      end

      doc.to_html
    end

    def render_link_stylesheet(asset, env = {})
      attributes = {
        "rel" => "stylesheet",
        "href" => asset.url
      }
      attributes.update(asset.attributes) if asset.attributes.is_a? Hash
      tag("link", attributes)
    end
  end
end

Roger::Renderer.helper RogerThemes::ViewHelper
