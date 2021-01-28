module CFE
  class Submission < ApplicationRecord
    include CFESubmissionStateMachine

    belongs_to :legal_aid_application
    has_many :submission_histories, -> { order(created_at: :asc) }, inverse_of: :submission
    has_one :result, class_name: 'BaseResult'

    delegate :passported?, :non_passported?, to: :legal_aid_application
  end
end
