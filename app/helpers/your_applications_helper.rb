module YourApplicationsHelper
  def home_path
    request.path_info.include?("providers") ? your_applications_default_tab_path : "#"
  end

  def your_applications_default_tab_path
    submitted_providers_legal_aid_applications_path
  end
end
