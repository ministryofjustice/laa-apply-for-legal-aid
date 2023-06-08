module Providers
  module Means
    class ReceivesStateBenefitsController < ProviderBaseController
      def show
        @form = ReceivesStateBenefitsForm.new(model: applicant)
      end

      def update
        @form = ReceivesStateBenefitsForm.new(form_params)
        if @form.save
          remove_state_benefits unless applicant.receives_state_benefits?
          go_forward(applicant.receives_state_benefits?)
        else
          render :show
        end
      end

    private

      def applicant
        legal_aid_application.applicant
      end

      def form_params
        merge_with_model(applicant) do
          params.require(:applicant).permit(:receives_state_benefits)
        end
      end

      def remove_state_benefits
        applicant.state_benefits.destroy_all
      end
    end
  end
end
