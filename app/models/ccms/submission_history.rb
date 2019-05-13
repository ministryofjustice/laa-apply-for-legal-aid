module CCMS
  class SubmissionHistory < ::ApplicationRecord
    self.table_name = :ccms_submission_histories

    belongs_to :submission
  end
end
