module Providers
  class DependantsController < ProviderBaseController
    def new
      @form = LegalAidApplications::DependantForm.new(model: dependant)
    end

    def show
      @form = LegalAidApplications::DependantForm.new(model: dependant)
    end

    def update
      @form = LegalAidApplications::DependantForm.new(form_params)
      if @form.save
        go_forward(dependant)
      else
        render @form.model.id.nil? ? :new : :show
      end
    end

    private

    def dependant
      @dependant ||= dependant_exists? || build_new_dependant
    end

    def dependant_exists?
      legal_aid_application.dependants.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      false
    end

    def build_new_dependant
      Dependant.new(
        legal_aid_application: legal_aid_application,
        number: legal_aid_application.dependants.count + 1
      )
    end

    def form_params
      merged_params = merge_with_model(dependant) do
        params.require(:dependant).permit(*LegalAidApplications::DependantForm::MODEL_ATTRIBUTES)
      end
      convert_date_params(merged_params)
    end
  end
end
