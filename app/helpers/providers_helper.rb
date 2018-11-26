module ProvidersHelper
  def provider_back_link(text = 'Back')
    link_to text, back_step_url, class: 'govuk-back-link', id: 'back-top', method: 'get'
  end
end
