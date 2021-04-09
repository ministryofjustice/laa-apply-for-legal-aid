module LegalFramework
  class Submission < ApplicationRecord
    belongs_to :legal_aid_application
    has_many :submission_histories, -> { order(created_at: :asc) }, inverse_of: :submission
  end
end
