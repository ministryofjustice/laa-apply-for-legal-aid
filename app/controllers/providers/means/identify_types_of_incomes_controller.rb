module Providers
  module Means
    class IdentifyTypesOfIncomesController < ProviderBaseController
      def show
        @none_selected = legal_aid_application.no_credit_transaction_types_selected?
      end

      def update
        synchronize_credit_transaction_types
        validate

        if legal_aid_application.errors.present?
          return continue_or_draft if draft_selected?

          render :show
        else
          legal_aid_application.update!(no_credit_transaction_types_selected: none_selected?)

          continue_or_draft
        end
      end

    private

      def validate
        legal_aid_application.errors.add :transaction_type_ids, t(".none_and_another_option_selected") if none_selected? && transaction_types_selected?
        legal_aid_application.errors.add :transaction_type_ids, t(".none_selected") if [none_selected?, transaction_types_selected?].all?(false)
      end

      def transaction_type_params
        params
          .require(:legal_aid_application)
          .permit(:none_selected, transaction_type_ids: [])
      end

      def transaction_types
        @transaction_types ||= TransactionType
          .credits
          .without_housing_benefits
          .with_children(ids: transaction_type_params[:transaction_type_ids])
      end

      def transaction_types_selected?
        transaction_types.present?
      end

      def none_selected?
        transaction_type_params[:none_selected] == "true"
      end

      def synchronize_credit_transaction_types
        existing_credit_transaction_type_ids = legal_aid_application.transaction_types.credits.pluck(:id)

        keep = transaction_types.each_with_object([]) do |form_tt, arr|
          add_transaction_type(form_tt) if existing_credit_transaction_type_ids.exclude?(form_tt.id)
          arr.append(form_tt.id)
        end
        destroy_all_credit_transaction_types(except: keep)
      end

      def add_transaction_type(transaction_type)
        LegalAidApplicationTransactionType.create(legal_aid_application:,
                                                  transaction_type:,
                                                  owner_type: "Applicant",
                                                  owner_id: legal_aid_application.applicant.id)
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
    end
  end
end
