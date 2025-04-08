module Task
  class Applicants < Base
    def path
      # TODO: this needs to go to the last step reached in the applicants task flow or the beginning of that task flow
      # if status.in_progress?
      #  last_task_page_path(self)
      # else
      providers_legal_aid_application_applicants_path(application)
      # end
    end
  end
end
