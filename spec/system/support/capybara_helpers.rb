module CapybaraHelpers
  def id_from_current_page_url
    path = URI.parse(page.current_url).path
    paths = path.split("/").reject! { |fragment| fragment.to_s.empty? }
    id_at = paths.find_index("applications")
    return paths[id_at + 1] if id_at

    raise "Unable to locate LegalAidApplication ID accurately"
  end
end
