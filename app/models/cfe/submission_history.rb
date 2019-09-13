module CFE
  class SubmissionHistory < ApplicationRecord
    self.table_name = :cfe_submission_histories

    belongs_to :submission
  end
end
