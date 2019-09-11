module CCMS
  class SubmissionDocument < ApplicationRecord
    self.table_name = :ccms_submission_documents

    belongs_to :submission
  end
end
