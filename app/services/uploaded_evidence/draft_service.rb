module UploadedEvidence
  class DraftService < Base
    def call
      populate_submission_form
      @next_action = :save_continue_or_draft

      self
    end
  end
end
