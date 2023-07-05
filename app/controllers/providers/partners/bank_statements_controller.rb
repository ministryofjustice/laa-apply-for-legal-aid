module Providers
  module Partners
    class BankStatementsController < Providers::BankStatementsController
      prefix_step_with :partner

    private

      def set_form
        @form = BankStatementForm.new(bank_statement_form_params)
      end

      def form
        @form ||= BankStatementForm.new(bank_statement_form_params)
      end

      def attachments
        legal_aid_application.attachments.partner_bank_statement_evidence
      end
    end
  end
end
