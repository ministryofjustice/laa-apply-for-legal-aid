module Providers
  module Partners
    class ReceivesStateBenefitsController < ProviderBaseController
      prefix_step_with :partner

      def show
        @form = ReceivesStateBenefitsForm.new(model: partner)
      end

      def update
        @form = ReceivesStateBenefitsForm.new(form_params)
        remove_state_benefits unless @form.receives_state_benefits?
        render :show unless save_continue_or_draft(@form, receives_state_benefits: @form.receives_state_benefits?)
      end

    private

      def partner
        legal_aid_application.partner
      end

      def form_params
        merge_with_model(partner) do
          params.expect(partner: [:receives_state_benefits])
        end
      end

      def remove_state_benefits
        partner.state_benefits.destroy_all
      end
    end
  end
end
