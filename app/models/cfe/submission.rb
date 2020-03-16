module CFE
  class Submission < ApplicationRecord
    include CFESubmissionStateMachine

    belongs_to :legal_aid_application
    has_many :submission_histories, -> { order(created_at: :asc) }
    has_many :submission_documents, -> { order(created_at: :asc) }
    has_one :result, class_name: 'BaseResult'
  end
end
