module TagHelper
  def gov_uk_tag(text:, type: nil, classes: [])
    classes << 'govuk-tag'
    classes << "#{type.to_s.dasherize}-tag" if type
    content_tag :strong, text, class: classes
  end
end
