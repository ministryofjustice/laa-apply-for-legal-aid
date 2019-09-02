module TagHelper
  def gov_uk_tag(text:, type:)
    type_class = "#{type.to_s.dasherize}-tag"
    content_tag :strong, text, class: "govuk-tag #{type_class}"
  end
end
