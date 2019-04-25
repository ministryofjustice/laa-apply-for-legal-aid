module CCMS
  class SubmissionHistory < ::ApplicationRecord
    self.table_name = :submission_histories

    belongs_to :submission
  end
end
