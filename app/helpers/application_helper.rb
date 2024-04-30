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

  def yes_no(boolean)
    boolean ? t("generic.yes") : t("generic.no")
  end

  def print_button(text)
    content_tag :button, text, class: "govuk-button govuk-button--secondary no-print print-button", type: "button"
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
