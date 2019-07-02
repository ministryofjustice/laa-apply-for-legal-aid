module Citizens
  class DependantDetailsController < BaseController
    include ApplicationFromSession
    helper_method :other_dependants

    def show
      @form = Dependants::BasicDetailsForm.new(model: dependant)
    end

    def update
      @form = Dependants::BasicDetailsForm.new(form_params)

      if @form.save
        go_forward(dependant)
      else
        render :show
      end
    end

    private

    def other_dependants
      @other_dependants ||= legal_aid_application.dependants.where.not(id: dependant.id)
    end

    def dependant
      @dependant ||= legal_aid_application.dependants.find(params[:id])
    end

    def form_params
      merge_with_model(dependant) do
        params.require(:dependant).permit(*Dependants::BasicDetailsForm::ATTRIBUTES)
      end
    end
  end
end
