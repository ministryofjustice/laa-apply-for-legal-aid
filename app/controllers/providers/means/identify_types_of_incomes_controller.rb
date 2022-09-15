module Providers
  module Means
    class IdentifyTypesOfIncomesController < ProviderBaseController
      before_action :redirect_if_enhanced_bank_upload_enabled

      def show
        @none_selected = legal_aid_application.no_credit_transaction_types_selected?
      end

      def update
        synchronize_credit_transaction_types

        if none_selected?
          legal_aid_application.update!(no_credit_transaction_types_selected: true)

          return continue_or_draft
        elsif transaction_types_selected?
          legal_aid_application.update!(no_credit_transaction_types_selected: false)

          return continue_or_draft
        end

        return continue_or_draft if draft_selected?

        legal_aid_application.errors.add :transaction_type_ids, t(".none_selected")
        render :show
      end

    private

      def legal_aid_application_params
        params.require(:legal_aid_application).permit(transaction_type_ids: [])
      end

      def transaction_types
        @transaction_types ||= TransactionType.credits.find_with_children(legal_aid_application_params[:transaction_type_ids])
      end

      def transaction_types_selected?
        transaction_types.present?
      end

      def none_selected?
        params[:legal_aid_application][:none_selected] == "true"
      end

      def synchronize_credit_transaction_types
        existing_credit_tt_ids = legal_aid_application.legal_aid_application_transaction_types.credits.map(&:transaction_type_id)

        keep = transaction_types.each_with_object([]) do |form_tt, arr|
          add_transaction_type(form_tt) if existing_credit_tt_ids.exclude?(form_tt.id)
          arr.append(form_tt.id)
        end

        destroy_all_credit_transaction_types(except: keep)
      end

      def add_transaction_type(transaction_type)
        legal_aid_application.transaction_types << transaction_type
      end

      def destroy_all_credit_transaction_types(except:)
        LegalAidApplication.transaction do
          legal_aid_application
            .legal_aid_application_transaction_types
            .credits
            .where.not(transaction_type_id: except)
            .destroy_all
        end
      end

      def redirect_if_enhanced_bank_upload_enabled
        if Setting.enhanced_bank_upload?
          redirect_to providers_legal_aid_application_means_regular_incomes_path(legal_aid_application)
        end
      end
    end
  end
end
