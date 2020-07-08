class HtmlPageSaver
  attr_accessor :html, :file_path, :asset_host

  def self.call(**args)
    new(**args).call
  end

  def initialize(html:, file_path:, asset_host:)
    @html = html
    @file_path = file_path
    @asset_host = asset_host
  end

  def call
    add_asset_host
    save_file
  end

  private

  def save_file
    File.write(prepared_path, html, mode: 'wb')
  end

  def prepared_path
    File.expand_path(file_path).tap do |path|
      FileUtils.mkdir_p(File.dirname(path))
    end
  end

  def add_asset_host
    match = html.match(/charset=['"]utf-8['"] *>/) || html.match(/<head[^<]*?>/) || return
    html.insert(match.end(0), "<base href=\"#{asset_host}\" />")
  end
end
