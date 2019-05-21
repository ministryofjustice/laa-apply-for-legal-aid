module ApplicationHelper
  def home_link
    link_url = '#'
    link_url = providers_legal_aid_applications_url if request.path_info.include?('providers')
    link_to(t('layouts.application.header.title'),
            link_url,
            class: 'govuk-header__link govuk-header__link--service-name')
  end

  def html_title
    default = t('shared.page-title.suffix')
    return default unless content_for?(:page_title)

    "#{content_for(:page_title)} - #{default}".html_safe
  end

  def controller_t(lazy_t, *args)
    controller = controller_path.split('/')
    t ".#{[*controller, lazy_t].join('.')}", *args
  end

  def menu_button
    button_tag(t('generic.menu'),
               type: 'button', role: 'button', class: 'govuk-header__menu-button js-header-toggle',
               aria: { controls: 'navigation', label: t('generic.toggle_navigation') })
  end

  def back_link(text: t('generic.back'), path: back_path, method: nil)
    return unless path

    link_to text, path, class: 'govuk-back-link', id: 'back', method: method
  end

  def current_journey
    return journey_type if respond_to?(:journey_type)

    journeys = %i[admin providers citizens]
    parent = controller.class.parent.to_s.downcase.to_sym
    return :unknown unless journeys.include?(parent)

    parent
  end

  def current_journey?(journey)
    current_journey == journey.to_s.downcase.to_sym
  end

  def user_header_link
    return admin_header_link if current_journey == :admin

    provider_header_link
  end

  def provider_header_link
    return unless provider_signed_in?

    render 'shared/provider_header_link'
  end

  def admin_header_link
    return unless admin_user_signed_in?

    button = button_to(
      t('layouts.logout.admin'),
      destroy_admin_user_session_path,
      method: :delete,
      class: 'button-as-link govuk-header__link'
    )

    content_tag(:li, button, class: 'govuk-header__navigation-item')
  end

  def list_from_translation_path(translation_path, params: {})
    render 'shared/forms/list_items', translation_path: translation_path, params: params
  end

  def yes_no(boolean)
    boolean ? t('generic.yes') : t('generic.no')
  end
end
