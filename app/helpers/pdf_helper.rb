module PdfHelper
  def apply_webpacker_stylesheet_pack_tag(source)
    file = Webpacker.manifest.lookup!(source, type: 'css')
    "<style type='text/css' media='all'>#{read_asset(file)}</style>".html_safe
  end
end
