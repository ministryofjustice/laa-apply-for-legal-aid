module Providers
  module Partners
    class BankStatementsController < Providers::BankStatementsController
      skip_back_history_for :list

      prefix_step_with :partner

      def show
        legal_aid_application.set_transaction_period
      end

    private

      def set_form
        @form = BankStatementForm.new(bank_statement_form_params)
      end

      def form
        @form ||= BankStatementForm.new(bank_statement_form_params)
      end

      def files_deleted_message(deleted_file_name)
        I18n.t("activemodel.attributes.providers/partners/bank_statement_form.file_deleted", file_name: deleted_file_name)
      end

      def successful_upload
        return if form.errors.present?

        I18n.t("activemodel.attributes.providers/partners/bank_statement_form.file_uploaded", file_name: form.original_file.original_filename)
      end

      def attachments
        legal_aid_application.attachments.part_bank_state_evidence
      end

      def url
        providers_legal_aid_application_partners_bank_statements_path
      end
    end
  end
end
