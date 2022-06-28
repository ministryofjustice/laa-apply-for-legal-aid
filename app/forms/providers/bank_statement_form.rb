module Providers
  class BankStatementForm < BaseFileUploaderForm
    form_for BankStatement

    attr_accessor :original_file, :original_filename, :provider_uploader, :upload_button_pressed

    def exclude_from_model
      %i[upload_button_pressed original_file original_filename]
    end

    validate :at_least_one_file_or_draft
    validate :file_uploaded?
    validate :original_file_valid

    def save
      result = super
      return unless original_file

      model.save!(validate: false) if attachments_made?
      result
    end

  private

    def create_attachment(original_file)
      model.legal_aid_application.attachments.create document: original_file,
                                                     attachment_type: "bank_statement_evidence",
                                                     original_filename: @original_file.original_filename,
                                                     attachment_name: sequenced_attachment_name
    end

    def at_least_one_file_or_draft
      return if file_present_or_draft?

      @errors.add(:original_file, :blank)
    end

    def file_present_or_draft?
      model.original_attachments.any? || original_file.present? || draft?
    end
  end
end
