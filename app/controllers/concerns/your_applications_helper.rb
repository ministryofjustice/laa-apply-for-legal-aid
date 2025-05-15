module YourApplicationsHelper
  extend ActiveSupport::Concern

  def your_applications_default_tab_path
    submitted_providers_legal_aid_applications_path
  end
end
