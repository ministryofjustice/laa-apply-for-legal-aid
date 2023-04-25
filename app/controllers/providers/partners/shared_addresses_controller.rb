module Providers
  module Partners
    class SharedAddressesController < ProviderBaseController
      def show
        @form = ::Partners::SharedAddressForm.new(model: partner)
      end

      def update
        @form = ::Partners::SharedAddressForm.new(form_params)
        render :show unless save_run_continue_or_draft(@form, method_to_run, shared_address: @form.shared_address_with_client?)
      end

    private

      def partner
        @partner ||= legal_aid_application.partner || legal_aid_application.build_partner
      end

      def form_params
        merge_with_model(partner) do
          params.require(:partner).permit(:shared_address_with_client)
        end
      end

      def method_to_run
        if @form.shared_address_with_client?
          :duplicate_applicants_address
        elsif answer_changing_from_true_to_false
          :clear_stored_address
        end
      end

      def answer_changing_from_true_to_false
        partner.shared_address_with_client == true && @form.shared_address_with_client? == false
      end
    end
  end
end
