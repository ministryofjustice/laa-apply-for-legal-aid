module CFE
  class SubmissionHistory < ApplicationRecord
    belongs_to :submission
  end
end
