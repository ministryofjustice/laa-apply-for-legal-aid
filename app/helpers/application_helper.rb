module ApplicationHelper
  def home_link
    link_url = '#'
    link_url = providers_legal_aid_applications_url if request.path_info.include?('providers')
    link_to(t('layouts.application.header.title'),
            link_url,
            class: 'govuk-header__link govuk-header__link--service-name')
  end
end
