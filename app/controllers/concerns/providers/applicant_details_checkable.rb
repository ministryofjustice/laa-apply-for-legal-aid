module Providers
  module ApplicantDetailsCheckable
  private

    def details_checked!
      legal_aid_application.applicant_details_checked!
    end

    def details_checked?
      legal_aid_application.applicant_details_checked?
    end
  end
end
