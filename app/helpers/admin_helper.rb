module AdminHelper
  def admin_nav_to(name, path)
    link_path, li_class = if current_page?(path)
                            ['#', 'current-page']
                          else
                            [path, nil]
                          end

    link = link_to_accessible name, link_path, class: 'govuk-link govuk-link--no-visited-state'
    content_tag :li, link, class: li_class
  end
end
