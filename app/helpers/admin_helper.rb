module AdminHelper
  def admin_nav_to(name, path)
    link_path, li_class = if current_page?(path)
                            ["#", "current-page"]
                          else
                            [path, nil]
                          end

    link = govuk_link_to name, link_path, { no_visited_state: true }
    content_tag :li, link, class: li_class
  end
end
