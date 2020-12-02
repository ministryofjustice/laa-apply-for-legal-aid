module AccessibleNavigationHelper
  def button_to_accessible(name = nil, options = nil, html_options = {}, &block)
    props = set_accessible_properties(name, html_options)
    button_to(name, options, props, &block)
  end

  def link_to_accessible(name = nil, options = nil, html_options = {}, &block)
    props = set_accessible_properties(name, html_options)
    link_to(name, options, props, &block)
  end

  def set_accessible_properties(name, options)
    suffix = options[:suffix]
    # match element label text only (excluding content tags) or use full label name
    name = name.scan(/^.+?(?=\s*<)/).first || name
    name = suffix ? "#{name} #{suffix}" : name
    options[:title] = name
    options[:aria] = { label: name }
    options
  end
end
