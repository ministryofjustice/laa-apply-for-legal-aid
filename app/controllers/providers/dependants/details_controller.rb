module Providers
  module Dependants
    class DetailsController < ProviderBaseController
      prefix_step_with :dependants
      helper_method :other_dependants

      def show
        @form = DependantForm::DetailsForm.new(model: dependant)
      end

      def update
        @form = DependantForm::DetailsForm.new(form_params)

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
        @dependant ||= legal_aid_application.dependants.find(params[:dependant_id])
      end

      def form_params
        merge_with_model(dependant) do
          params.require(:dependant).permit(*DependantForm::DetailsForm::ATTRIBUTES)
        end
      end
    end
  end
end
