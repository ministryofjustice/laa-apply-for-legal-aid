module Providers
  module Means
    class RegularOutgoingsController < ProviderBaseController
      before_action :redirect_unless_enhanced_bank_upload_enabled

      def show
        @form = RegularOutgoingsForm.new
      end

      def update
        @form = RegularOutgoingsForm.new(regular_outgoings_params)

        if @form.save
          go_forward
        else
          render :show, status: :unprocessable_entity
        end
      end

    private

      def regular_outgoings_params
        params
          .require(:providers_means_regular_outgoings_form)
          .permit(regular_payment_params, outgoing_types: [])
          .merge(legal_aid_application_id: legal_aid_application.id)
      end

      def regular_payment_params
        RegularOutgoingsForm::OUTGOING_TYPES.map { |outgoing_type|
          ["#{outgoing_type}_amount".to_sym, "#{outgoing_type}_frequency".to_sym]
        }.flatten
      end

      def redirect_unless_enhanced_bank_upload_enabled
        unless Setting.enhanced_bank_upload?
          redirect_to providers_legal_aid_application_means_identify_types_of_outgoing_path(legal_aid_application)
        end
      end
    end
  end
end
