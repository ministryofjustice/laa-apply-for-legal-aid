module CFE
  module V2
    class Submission < ApplicationRecord
      include CFESubmissionStateMachine

      belongs_to :legal_aid_application
      has_many :submission_histories, -> { order(created_at: :asc) }
      has_one :result
    end
  end
end
