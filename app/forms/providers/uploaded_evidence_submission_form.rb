module Providers
  class UploadedEvidenceSubmissionForm < BaseFileUploaderForm
    form_for UploadedEvidenceCollection

    attr_accessor :provider_uploader
  end
end
