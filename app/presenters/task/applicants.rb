module Task
  class Applicants < Base
    # uri/path to the section start page/form
    def path
      providers_legal_aid_application_applicants_path(application)
    end
  end
end
