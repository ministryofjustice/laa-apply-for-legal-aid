module CCMS
  class SubmissionHistory < ::ApplicationRecord
    belongs_to :submission
  end
end
