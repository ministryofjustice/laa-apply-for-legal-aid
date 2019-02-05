module ProvidersHelper
  def provider_back_link(text: t('generic.back'), path: back_path, method: :get)
    link_to text, path, class: 'govuk-back-link', id: 'back-top', method: method
  end

  def url_for_application(legal_aid_application)
    name = legal_aid_application.provider_step.presence || :proceedings_types

    Flow::ProviderFlowService.new(
      legal_aid_application: legal_aid_application,
      current_step: name.to_sym
    ).current_path
  end
end
