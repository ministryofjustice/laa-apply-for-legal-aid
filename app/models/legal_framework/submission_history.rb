module LegalFramework
  class SubmissionHistory < ApplicationRecord
    belongs_to :submission
  end
end
