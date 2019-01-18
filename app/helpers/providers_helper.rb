module ProvidersHelper
  def provider_back_link(text: t('generic.back'), path: back_step_url, method: :get)
    link_to text, path, method: method, class: 'govuk-back-link', id: 'back-top'
  end

  def provider_basic_page(page_title:, back_link: nil, column_width: 'two-thirds', &content)
    render(
      'shared/providers/basic_page_template',
      page_title: page_title,
      back_link: back_link,
      column_width: column_width,
      content: capture(&content)
    )
  end
end
