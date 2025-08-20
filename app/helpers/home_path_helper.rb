module HomePathHelper
  def home_path
    return citizens_legal_aid_applications_path if citizen_journey?
    return your_applications_default_tab_path if provider_journey? && !before_applications_page?

    root_path
  end

private

  def provider_journey?
    request.path.starts_with?("/providers")
  end

  def citizen_journey?
    request.path.starts_with?("/citizens")
  end

  def before_applications_page?
    [providers_confirm_office_path, providers_select_office_path, providers_provider_path].any? { |page| request.path.include?(URI.parse(page).path) }
  end
end
