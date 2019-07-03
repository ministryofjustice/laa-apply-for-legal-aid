module Citizens
  class DependantsController < BaseController
    include ApplicationFromSession
    helper_method :other_dependants

    def index
      @form = DependantForm::DetailsForm.new(model: dependant)
    end

    def create
      @form = DependantForm::DetailsForm.new(form_params)

      if @form.save
        replace_last_page_in_history(edit_dependant_path)
        go_forward(dependant)
      else
        render :index
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
      citizens_dependant_details_path(dependant.id)
    end

    def form_params
      merge_with_model(dependant) do
        params.require(:dependant).permit(*DependantForm::DetailsForm::ATTRIBUTES)
      end
    end
  end
end
