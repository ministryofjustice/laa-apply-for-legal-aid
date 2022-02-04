module Providers
  class UploadedEvidenceSubmissionForm < BaseFileUploaderForm
    form_for UploadedEvidenceCollection

    attr_accessor :original_file, :provider_uploader, :upload_button_pressed

    # TODO: method will need to be changed on the validation ticket
    # https://dsdmoj.atlassian.net/browse/AP-2739 and the nocov removed
    # :nocov:
    def files?
      # For now we return if it is empty so application can progress to the next page
      # but the line below will need to be removed
      return true if original_file.nil?

      original_file.present?
    end
    # :nocov:
  end
end
