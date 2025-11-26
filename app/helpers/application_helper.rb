module ApplicationHelper
  include YourApplicationsHelper
  include HomePathHelper

  def html_title
    default = t("shared.page-title.suffix")
    return default unless content_for?(:head_title) || content_for?(:page_title)

    title = content_for?(:head_title) ? content_for(:head_title) : content_for(:page_title)
    "#{title} - #{default}".html_safe
  end

  def controller_t(lazy_t, **)
    controller = controller_path.split("/")
    t(".#{[*controller, lazy_t].join('.')}", **)
  end

  def back_link(text: t("generic.back"), path: back_path, method: nil)
    return unless path

    govuk_back_link(href: path, text:, classes: "no-print", html_attributes: { id: "back", "data-method": method })
  end

  def current_journey
    return journey_type if respond_to?(:journey_type)

    journeys = %i[admin providers citizens]
    namespace = controller_path.split("/").first&.to_sym

    return :unknown unless journeys.include?(namespace)

    namespace
  end

  def user_header_navigation
    return if current_journey == :citizens
    return admin_header_navigation if current_journey == :admin

    provider_header_navigation
  end

  def provider_header_navigation
    if provider_signed_in?
      safe_join([
        content_tag(:li, link_to(current_provider.email, providers_provider_path, class: "moj-header__navigation-link"), class: "moj-header__navigation-item"),
        content_tag(:li, link_to(t("layouts.logout.provider"), destroy_provider_session_path, class: "moj-header__navigation-link", method: :delete), class: "moj-header__navigation-item"),
      ])
    else
      return if Setting.out_of_hours?

      content_tag(:li, link_to(t("layouts.login"), providers_select_office_path, class: "moj-header__navigation-link"), class: "moj-header__navigation-item")
    end
  end

  def admin_header_navigation
    return unless admin_user_signed_in?

    content_tag(:li, class: "moj-header__navigation-item") do
      link_to(t("layouts.logout.admin"), destroy_admin_user_session_path, class: "moj-header__navigation-link", method: :delete)
    end
  end

  def yes_no(boolean)
    boolean ? t("generic.yes") : t("generic.no")
  end

  def print_button(text, primary: nil)
    content_tag :button, text, class: "govuk-button #{'govuk-button--secondary' unless primary} no-print print-button", type: "button"
  end

  def linked_children_names(proceeding)
    proceeding.involved_children.map(&:full_name).join("</br>").html_safe
  end

  def govuk_footer_meta_items
    if Setting.out_of_hours?
      {
        t("layouts.application.footer.research_panel") => ENV.fetch("RESEARCH_PANEL_FORM_LINK", root_path),
        t("layouts.application.footer.cookies") => "https://www.gov.uk/help/cookies",
        t("layouts.application.footer.terms") => "https://www.gov.uk/government/publications/laa-online-portal-help-and-information",
        t("layouts.application.footer.digital_services_html") => "https://mojdigital.blog.gov.uk",
      }.freeze
    else
      {
        t("layouts.application.footer.downtime_help") => "downtime_help#guidance",
        t("layouts.application.footer.contact") => contact_path,
        t("layouts.application.footer.feedback") => new_feedback_path,
        t("layouts.application.footer.research_panel") => ENV.fetch("RESEARCH_PANEL_FORM_LINK", root_path),
        # Currently we can only update and store cookie preferences for the provider, citizen users are shown the generic GOV.UK cookies page
        t("layouts.application.footer.cookies") => (current_provider ? providers_cooky_path(current_provider) : "https://www.gov.uk/help/cookies"),
        t("layouts.application.footer.privacy_policy") => privacy_policy_index_path,
        t("layouts.application.footer.accessibility_statement") => accessibility_statement_index_path,
        t("layouts.application.footer.terms") => "https://www.gov.uk/government/publications/laa-online-portal-help-and-information",
        t("layouts.application.footer.digital_services_html") => "https://mojdigital.blog.gov.uk",
      }.freeze
    end
  end

  def application_ref_non_breaking(application_ref)
    application_ref.tr("-", "\u2011")
  end

  def phase_banner_tag
    return { text: t("layouts.application.header.staging"), colour: "orange" } if HostEnv.staging?
    return { text: t("layouts.application.header.uat"), colour: "purple" } if HostEnv.uat?
    return { text: t("layouts.application.header.development"), colour: "green" } if HostEnv.development?

    { text: t("layouts.application.header.phase") }
  end
end
