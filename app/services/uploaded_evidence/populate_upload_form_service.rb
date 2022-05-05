module UploadedEvidence
  class PopulateUploadFormService < Base
    def call
      populate_upload_form
      uploaded_evidence_collection
      @next_action = :show

      self
    end
  end
end
