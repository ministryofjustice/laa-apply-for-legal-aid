module TagHelper
  STATUS_TAGS = {
    in_progress: 'govuk-tag--blue',
    submitted: 'govuk-tag--green'
  }.freeze

  def gov_uk_tag(text:, status: nil, classes: [])
    classes << 'govuk-tag no-wrap'
    classes << STATUS_TAGS[status.to_sym] if status
    content_tag :strong, text, class: classes
  end
end
