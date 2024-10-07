module Providers
  module Means
    class IdentifyTypesOfOutgoingsController < ProviderBaseController
      def show
        @none_selected = legal_aid_application.no_debit_transaction_types_selected?
      end

      def update
        synchronize_debit_transaction_types
        validate

        if legal_aid_application.errors.present?
          return continue_or_draft if draft_selected?

          render :show
        else
          legal_aid_application.update!(no_debit_transaction_types_selected: none_selected?)

          continue_or_draft
        end
      end

    private

      def validate
        legal_aid_application.errors.add :transaction_type_ids, t(".none_and_another_option_selected") if none_selected? && transaction_types_selected?
        legal_aid_application.errors.add :transaction_type_ids, t(".none_selected") if [none_selected?, transaction_types_selected?].all?(false)
      end

      def legal_aid_application_params
        params.require(:legal_aid_application).permit(transaction_type_ids: [])
      end

      def transaction_types
        @transaction_types ||= TransactionType.debits.where(id: legal_aid_application_params[:transaction_type_ids])
      end

      def transaction_types_selected?
        transaction_types.present?
      end

      def none_selected?
        params[:legal_aid_application][:none_selected] == "true"
      end

      def synchronize_debit_transaction_types
        existing_debit_tt_ids = legal_aid_application.legal_aid_application_transaction_types.debits.map(&:transaction_type_id)

        keep = transaction_types.each_with_object([]) do |form_tt, arr|
          add_transaction_type(form_tt) if existing_debit_tt_ids.exclude?(form_tt.id)
          arr.append(form_tt.id)
        end

        destroy_all_debit_transaction_types(except: keep)
      end

      def add_transaction_type(transaction_type)
        LegalAidApplicationTransactionType.create(legal_aid_application:,
                                                  transaction_type:,
                                                  owner_type: "Applicant",
                                                  owner_id: legal_aid_application.applicant.id)
      end

      def destroy_all_debit_transaction_types(except:)
        LegalAidApplication.transaction do
          legal_aid_application
            .legal_aid_application_transaction_types
            .debits
            .where.not(transaction_type_id: except)
            .destroy_all
        end
      end
    end
  end
end
