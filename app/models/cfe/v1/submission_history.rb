module CFE
  module V1
    class SubmissionHistory < ApplicationRecord
      belongs_to :submission
    end
  end
end
