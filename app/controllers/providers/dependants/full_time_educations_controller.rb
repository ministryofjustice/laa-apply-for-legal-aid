module Providers
  module Dependants
    class FullTimeEducationsController < ProviderBaseController
      prefix_step_with :dependants

      def show
        @form = DependantForm::FullTimeEducationForm.new(model: dependant)
      end

      def update
        @form = DependantForm::FullTimeEducationForm.new(form_params)

        if @form.save
          go_forward(dependant)
        else
          render :show
        end
      end

      private

      def dependant
        @dependant ||= legal_aid_application.dependants.find(params[:dependant_id])
      end

      def form_params
        return { model: dependant } if params[:dependant].blank?

        merge_with_model(dependant) do
          params.require(:dependant).permit(:in_full_time_education)
        end
      end
    end
  end
end
