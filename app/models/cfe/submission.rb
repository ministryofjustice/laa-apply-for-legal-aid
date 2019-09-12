module CFE
  class Submission < ApplicationRecord
    include CFESubmissionStateMachine

    belongs_to :legal_aid_application

  end
end
