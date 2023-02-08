module ApplicationHelper
  def home_link
    request.path_info.include?("providers") ? providers_legal_aid_applications_url : "#"
  end

  def html_title
    default = t("shared.page-title.suffix")
    return default unless content_for?(:head_title) || content_for?(:page_title)

    title = content_for?(:head_title) ? content_for(:head_title) : content_for(:page_title)
    "#{title} - #{default}".html_safe
  end

  def controller_t(lazy_t, **args)
    controller = controller_path.split("/")
    t ".#{[*controller, lazy_t].join('.')}", **args
  end

  def back_link(text: t("generic.back"), path: back_path, method: nil)
    return unless path

    link_to_accessible text, path, class: "govuk-back-link no-print", id: "back", method:
  end

  def current_journey
    return journey_type if respond_to?(:journey_type)

    journeys = %i[admin providers citizens]
    parent = controller.class.module_parent.to_s.downcase.to_sym
    return :unknown unless journeys.include?(parent)

    parent
  end

  def user_header_navigation(header)
    return if current_journey == :citizens
    return admin_header_navigation(header) if current_journey == :admin

    provider_header_navigation(header)
  end

  def provider_header_navigation(header)
    if provider_signed_in?
      header.with_navigation_item(text: current_provider.username, href: providers_provider_path, active: false)
      header.with_navigation_item(text: t("layouts.logout.provider"), href: destroy_provider_session_path, active: false, options: { method: :delete })
    else
      header.with_navigation_item(text: t("layouts.login"), href: providers_legal_aid_applications_path, active: false)
    end
  end

  def admin_header_navigation(header)
    return unless admin_user_signed_in?

    header.with_navigation_item(text: t("layouts.logout.admin"), href: destroy_admin_user_session_path, active: false, options: { method: :delete })
  end

  def list_from_translation_path(translation_path, params: {})
    prefix = current_journey && current_journey != :unknown ? current_journey.to_s : ""
    bullet_list = params[:no_bullet] ? "" : "govuk-list--bullet"
    render "shared/forms/list_items", translation_path: prefix + translation_path, bullet_list:, params:
  end

  def bullet_list_from_translation_array(locale_path, params: {})
    keys = [I18n.locale, locale_path.split(".").map(&:to_sym)].flatten
    render "shared/forms/list_with_items", locale_path:, items: I18n.backend.send(:translations).dig(*keys), params:
  end

  def yes_no(boolean)
    boolean ? t("generic.yes") : t("generic.no")
  end

  def print_button(text)
    content_tag :button, text, class: "govuk-button govuk-button--secondary no-print print-button", type: "button"
  end

  def start_button_label(button_text)
    "#{t("generic.#{button_text}")} ".html_safe << content_tag(:svg,
                                                               content_tag(:path, "", fill: "currentColor", d: "M0 0h13l20 20-20 20H0l20-20z"),
                                                               class: "govuk-button__start-icon",
                                                               xmlns: "http://www.w3.org/2000/svg",
                                                               height: "19",
                                                               viewBox: "0 0 33 40",
                                                               role: "presentation",
                                                               focusable: "false")
  end

  def linked_children_names(proceeding)
    proceeding.involved_children.map(&:full_name).join("</br>").html_safe
  end

  def govuk_footer_meta_items
    {
      t("layouts.application.footer.contact") => contact_path,
      t("layouts.application.footer.feedback") => new_feedback_path,
      # Currently we can only update and store cookie preferences for the provider, citizen users are shown the generic GOV.UK cookies page
      t("layouts.application.footer.cookies") => (current_provider ? providers_cooky_path(current_provider) : "https://www.gov.uk/help/cookies"),
      t("layouts.application.footer.privacy_policy") => privacy_policy_index_path,
      t("layouts.application.footer.accessibility_statement") => accessibility_statement_index_path,
      t("layouts.application.footer.terms") => "https://www.gov.uk/government/publications/laa-online-portal-help-and-information",
      t("layouts.application.footer.digital_services_html") => "https://mojdigital.blog.gov.uk",
    }.freeze
  end
end
