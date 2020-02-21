module CFE
  module V2
    class SubmissionHistory < ApplicationRecord
      belongs_to :submission
    end
  end
end
