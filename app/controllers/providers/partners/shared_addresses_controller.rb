module Providers
  module Partners
    class SharedAddressesController < ProviderBaseController
      def show
        @form = ::Partners::SharedAddressForm.new(model: partner)
      end

      def update
        @form = ::Partners::SharedAddressForm.new(form_params)
        run_method = @form.shared_address_with_client? ? :duplicate_applicants_address : nil
        render :show unless save_run_continue_or_draft(@form, run_method, shared_address: @form.shared_address_with_client?)
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
    end
  end
end
