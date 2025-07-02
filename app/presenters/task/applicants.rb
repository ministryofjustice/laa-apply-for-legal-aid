module Task
  class Applicants < Base
    def path
      providers_legal_aid_application_applicant_details_path(application)
    end
  end
end
