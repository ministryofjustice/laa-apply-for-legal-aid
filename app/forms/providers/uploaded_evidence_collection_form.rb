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

    def files?
      original_file.present?
    end

    private
    def create_attachment(original_file)
      model.legal_aid_application.attachments.create document: original_file,
                                                     attachment_type: 'uncategorised',
                                                     original_filename: @original_file.original_filename,
                                                     attachment_name: sequenced_attachment_name
    end
  end
end
