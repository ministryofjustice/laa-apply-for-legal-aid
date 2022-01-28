module Providers
  class UploadedEvidenceSubmissionForm < BaseFileUploaderForm
    form_for UploadedEvidenceCollection

    attr_accessor :original_file, :provider_uploader, :upload_button_pressed

    def files?
      # Validation needs to remove the empty? check done below
      # at present we need to advance with or without an attached file
      return true if original_file.nil?

      original_file.present?
    end
  end
end
