module Providers
  class UploadedEvidenceCollectionForm < BaseFileUploaderForm
    form_for UploadedEvidenceCollection

    attr_accessor :original_file, :provider_uploader, :upload_button_pressed, :attachment_type

    validate :original_file_valid
    validate :file_uploaded?

    def save
      return if original_file.nil?

      model.save(validate: false) if attachments_made?
    end

    # TODO: method will need to be changed on the validation ticket
    # https://dsdmoj.atlassian.net/browse/AP-2739 and the nocov removed
    # :nocov:
    def files?
      # For now we return if it is empty so application can progress to the next page
      # but the line below will need to be removed
      return if files.empty?

      original_file.present?
    end
    # :nocov:

    private

    def create_attachment(original_file)
      model.legal_aid_application.attachments.create document: original_file,
                                                     attachment_type: 'uncategorised',
                                                     original_filename: @original_file.original_filename,
                                                     attachment_name: sequenced_attachment_name
    end
  end
end
