module Task
  class ProceedingsTypes < Base
    # uri/path to the section start page/form
    def path
      if status.not_started?
        Flow::Steps::ProviderStart::ProceedingsTypesStep.path.call(application)
      else
        # TODO: this needs to go to the last step reached in the proceeding_types OR has other proceedings page to allow for addition
        # of more proceedings.
        # if status.in_progress?
        #  last_task_page_path(self)
        # else
        providers_legal_aid_application_has_other_proceedings_path(application)
        # end
      end
    end
  end
end
