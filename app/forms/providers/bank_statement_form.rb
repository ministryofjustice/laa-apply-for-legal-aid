module Providers
  class BankStatementForm < BaseFileUploaderForm
    # this is just a patch to mock the current pattern as we
    # are not passing model params from the controller
    # and not relying on there being a model instance
    form_for BankStatement

    attr_accessor :original_file,
                  :original_filename,
                  :legal_aid_application_id,
                  :upload_button_pressed

    validate :at_least_one_file_or_draft

    # Files already uploaded and created with bank statement associations
    # so we do not need to save anything at this point, only to validate that
    # there is one or more bank statements or the the application is draft
    def save
      valid?
    end

    def upload
      return if original_file.nil?

      validate_original_file
      create_attachment(original_file) if errors.blank?
    end

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find(legal_aid_application_id)
    end

    def provider_uploader
      legal_aid_application.provider
    end

  private

    def at_least_one_file_or_draft
      return if any_bank_statements_or_draft?

      @errors.add(:original_file, :no_file_chosen)
    end

    def any_bank_statements_or_draft?
      legal_aid_application.attachments.bank_statement_evidence.any? || draft?
    end

    # can be shared with v1 bank statement controller
    def create_attachment(file)
      attachment = legal_aid_application
                    .attachments.create!(document: file,
                                         attachment_type: "bank_statement_evidence",
                                         original_filename: file.original_filename,
                                         attachment_name: sequenced_attachment_name)

      legal_aid_application
        .bank_statements
        .create!(legal_aid_application_id: legal_aid_application.id,
                 provider_uploader_id: provider_uploader.id,
                 attachment_id: attachment.id)

      PdfConverterWorker.perform_async(attachment.id)
    end

    # can be shared with v1 bank statement controller
    def sequenced_attachment_name
      if legal_aid_application.attachments.bank_statement_evidence.any?
        most_recent_name = legal_aid_application.attachments.bank_statement_evidence.order(:attachment_name).last.attachment_name
        increment_name(most_recent_name)
      else
        name
      end
    end

    def validate_original_file
      self.original_filename = original_file.original_filename
      scanner_down(original_file)
      malware_scan(original_file)
      file_empty(original_file)
      disallowed_content_type(original_file)
      too_big(original_file)
    end
  end
end
