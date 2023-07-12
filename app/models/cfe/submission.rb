module CFE
  class Submission < ApplicationRecord
    include CFESubmissionStateMachine

    belongs_to :legal_aid_application
    has_many :submission_histories, -> { order(created_at: :asc) }, inverse_of: :submission
    has_one :result, class_name: "BaseResult", dependent: :destroy

    delegate :passported?, :non_passported?, :uploading_bank_statements?, to: :legal_aid_application

    def version_6?
      return false if cfe_result.nil?

      JSON.parse(cfe_result)["version"].eql?("6")
    end
  end
end
