module YourApplicationsHelper
  def home_path
    substrings = ["providers", "/test/trapped_error"]
    substrings.any? { |substr| request.path_info.include?(substr) } ? your_applications_default_tab_path : "#"
  end

  def your_applications_default_tab_path
    submitted_providers_legal_aid_applications_path
  end
end
