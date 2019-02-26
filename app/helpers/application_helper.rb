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

  def back_link(text: t('generic.back'), path: back_path, method: nil)
    return unless path

    link_to text, path, class: 'govuk-back-link', id: 'back', method: method
  end

  def current_journey
    journeys = %i[Admin Providers Citizens]
    parent = controller.class.parent.to_s.to_sym
    return :Unknown unless journeys.include?(parent)

    parent
  end

  def user_header_link
    return admin_header_link if current_journey == :Admin

    provider_header_link
  end

  def provider_header_link
    return unless provider_signed_in?

    html = ''
    # TODO: - set the link to point at Provider Profile page when that page exists
    #        and use the full name rather than user name when that is available
    html << content_tag(:li, link_to(current_provider.username.truncate(20), providers_provider_path, class: 'govuk-header__link'), class: 'govuk-header__navigation-item')
    html << content_tag(:li, link_to('Sign out', destroy_provider_session_path, method: :delete, class: 'govuk-header__link'), class: 'govuk-header__navigation-item')
    html = sanitize html, tags: %w[a li], attributes: %w[href class rel data-method]
    html = content_tag :ul, html, id: 'navigation', class: 'govuk-header__navigation', 'aria-label': 'Top Level Navigation'
    content_tag :span, html, class: 'user-info'
  end

  def admin_header_link
    return unless admin_user_signed_in?

    content_tag(:li, link_to('Admin sign out', destroy_admin_user_session_path, method: :delete, class: 'govuk-header__link'), class: 'govuk-header__navigation-item')
  end

  def list_from_translation_path(translation_path)
    render 'shared/forms/list_items', translation_path: translation_path
  end
end
