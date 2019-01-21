module ProvidersHelper
  def provider_back_link(text: t('generic.back'), path: back_step_url, method: :get)
    link_to text, path, class: 'govuk-back-link', id: 'back-top', method: method
  end
end
