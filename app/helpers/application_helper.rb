module ApplicationHelper
  def home_link
    link_url = '#'
    link_url = providers_legal_aid_applications_url if request.path_info.include?('providers')
    link_to_accessible(t('layouts.application.header.title'),
                       link_url,
                       class: 'govuk-header__link govuk-header__link--service-name')
  end

  def html_title
    default = t('shared.page-title.suffix')
    return default unless content_for?(:head_title) || content_for?(:page_title)

    title = content_for?(:head_title) ? content_for(:head_title) : content_for(:page_title)
    "#{title} - #{default}".html_safe
  end

  def controller_t(lazy_t, **args)
    controller = controller_path.split('/')
    t ".#{[*controller, lazy_t].join('.')}", **args
  end

  def menu_button
    button_tag(t('generic.menu'),
               type: 'button', role: 'button', class: 'govuk-header__menu-button govuk-js-header-toggle',
               aria: { controls: 'navigation', label: t('generic.toggle_navigation') })
  end

  def back_link(text: t('generic.back'), path: back_path, method: nil)
    return unless path

    link_to_accessible text, path, class: 'govuk-back-link', id: 'back', method: method
  end

  def current_journey
    return journey_type if respond_to?(:journey_type)

    journeys = %i[admin providers citizens]
    parent = controller.class.module_parent.to_s.downcase.to_sym
    return :unknown unless journeys.include?(parent)

    parent
  end

  def user_header_link
    return admin_header_link if current_journey == :admin

    provider_header_link
  end

  def provider_header_link
    if provider_signed_in?
      render 'shared/provider_header_link'
    else
      render 'shared/signed_out_header_link'
    end
  end

  def admin_header_link
    return unless admin_user_signed_in?

    button = button_to_accessible(
      t('layouts.logout.admin'),
      destroy_admin_user_session_path,
      method: :delete,
      class: 'button-as-link govuk-header__link'
    )

    content_tag(:li, button, class: 'govuk-header__navigation-item')
  end

  def list_from_translation_path(translation_path, params: {})
    prefix = current_journey && current_journey != :unknown ? current_journey.to_s : ''
    render 'shared/forms/list_items', translation_path: prefix + translation_path, params: params
  end

  def yes_no(boolean)
    boolean ? t('generic.yes') : t('generic.no')
  end

  def print_button(text)
    content_tag :button, text, class: 'govuk-button no-print print-button', type: 'button'
  end

  def start_button_label(button_text)
    "#{t("generic.#{button_text}")} ".html_safe << content_tag(:svg,
                                                               content_tag(:path, '', fill: 'currentColor', d: 'M0 0h13l20 20-20 20H0l20-20z'),
                                                               class: 'govuk-button__start-icon',
                                                               xmlns: 'http://www.w3.org/2000/svg',
                                                               height: '19',
                                                               viewBox: '0 0 33 40',
                                                               role: 'presentation',
                                                               focusable: 'false')
  end

  def linked_children_names(application_proceeding_type)
    application_proceeding_type.involved_children.map(&:full_name).join('</br>').html_safe
  end
end
