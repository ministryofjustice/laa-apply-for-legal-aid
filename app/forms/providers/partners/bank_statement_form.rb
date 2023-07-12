module Providers
  module Partners
    class BankStatementForm < Providers::BankStatementForm
      def initialize(bank_statement_form_params)
        super(bank_statement_form_params)
        @attachment_type = "partner_bank_statement_evidence"
        @attachment_type_capture = /^#{@attachment_type}_(\d+)$/
      end

    private

      def any_bank_statements_or_draft?
        legal_aid_application.attachments.partner_bank_statement_evidence.any? || draft?
      end

      # can be shared with v1 bank statement controller
      def sequenced_attachment_name
        if legal_aid_application.attachments.partner_bank_statement_evidence.any?
          most_recent_name = legal_aid_application.attachments.partner_bank_statement_evidence.order(:created_at, :attachment_name).last.attachment_name
          increment_name(most_recent_name)
        else
          @attachment_type
        end
      end
    end
  end
end
