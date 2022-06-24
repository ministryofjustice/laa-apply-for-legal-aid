module Providers
  class BankStatementUploadForm < BaseFileUploaderForm
    form_for BankStatementUpload

    attr_accessor :statement, :original_file, :original_filename, :provider_uploader, :upload_button_pressed

    def exclude_from_model
      %i[upload_button_pressed original_file original_filename]
    end

    validate :statement_present_or_file_uploaded
    validate :file_uploaded?
    validate :original_file_valid

    def save
      return unless original_file

      model.save!(validate: false) if attachments_made?
    end

  private

    def create_attachment(original_file)
      model.legal_aid_application.attachments.create document: original_file,
                                                     attachment_type: "client_bank_statement",
                                                     original_filename: @original_file.original_filename,
                                                     attachment_name: sequenced_attachment_name
    end
  end
end
