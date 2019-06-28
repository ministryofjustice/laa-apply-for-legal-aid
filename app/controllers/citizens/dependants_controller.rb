module Citizens
  class DependantsController < BaseController
    include ApplicationFromSession
    helper_method :other_dependants

    def new
      @form = Dependants::BasicDetailsForm.new(model: dependant)
    end

    def create
      @form = Dependants::BasicDetailsForm.new(form_params)

      if @form.save
        replace_last_page_in_history(edit_dependant_path)
        flow_param(dependant)
        go_forward
      else
        render :new
      end
    end

    private

    def other_dependants
      @other_dependants ||= legal_aid_application.dependants
    end

    def dependant
      @dependant ||= Dependant.new(
        legal_aid_application: legal_aid_application,
        number: legal_aid_application.dependants.count + 1
      )
    end

    def edit_dependant_path
      citizens_dependant_detail_path(dependant.id)
    end

    def form_params
      merge_with_model(dependant) do
        params.require(:dependant).permit(*Dependants::BasicDetailsForm::ATTRIBUTES)
      end
    end
  end
end
