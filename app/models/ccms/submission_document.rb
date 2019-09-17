module CCMS
  class SubmissionDocument < ApplicationRecord
    belongs_to :submission
  end
end
