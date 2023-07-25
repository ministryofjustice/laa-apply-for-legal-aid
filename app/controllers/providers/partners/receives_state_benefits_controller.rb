module Providers
  module Partners
    class ReceivesStateBenefitsController < ProviderBaseController
      prefix_step_with :partner

      def show
        @form = ReceivesStateBenefitsForm.new(model: partner)
      end

      def update
        @form = ReceivesStateBenefitsForm.new(form_params)
        if @form.save
          remove_state_benefits unless partner.receives_state_benefits?
          go_forward(partner.receives_state_benefits?)
        else
          render :show
        end
      end

    private

      def partner
        legal_aid_application.partner
      end

      def form_params
        merge_with_model(partner) do
          params.require(:partner).permit(:receives_state_benefits)
        end
      end

      def remove_state_benefits
        partner.state_benefits.destroy_all
      end
    end
  end
end
