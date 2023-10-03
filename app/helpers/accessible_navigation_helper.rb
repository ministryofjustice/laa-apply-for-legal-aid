module AccessibleNavigationHelper
  def govuk_link_to(name = nil, options = nil, html_options = {}, &)
    props = set_accessible_properties(name, html_options)
    link_to(name, options, props, &)
  end

  def set_accessible_properties(name, options)
    suffix = options[:suffix]
    # match element label text only (excluding content tags) or use full label name
    name = name.scan(/^.+?(?=\s*<)/).first || name
    name = "#{name} #{suffix}" if suffix
    options[:aria] = { label: name }
    options
  end
end
