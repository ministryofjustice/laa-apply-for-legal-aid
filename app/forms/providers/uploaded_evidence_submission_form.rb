module Providers
  class UploadedEvidenceSubmissionForm < BaseFileUploaderForm
    form_for UploadedEvidenceCollection

    # def save
    #   return if original_file.nil?
    #
    #   model.save(validate: false) if attachments_made?
    # end

    attr_accessor :original_file, :provider_uploader, :upload_button_pressed

    def files?
      original_file.present?
    end

    private
    # def update_attachment(original_file, new_attachment_name)
    #   model.legal_aid_application.attachments.create document: original_file,
    #                                                  attachment_type: new_attachment_name,
    #                                                  original_filename: @original_file.original_filename,
    #                                                  attachment_name: sequenced_attachment_name
    # end
  end
end
