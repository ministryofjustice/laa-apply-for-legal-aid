module CFE
  class Submission < ApplicationRecord
    include CFESubmissionStateMachine

    self.table_name = :cfe_submissions

    belongs_to :legal_aid_application
  end
end
