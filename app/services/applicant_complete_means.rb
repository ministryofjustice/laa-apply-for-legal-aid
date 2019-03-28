class ApplicantCompleteMeans
  def self.call(legal_aid_application)
    new(legal_aid_application).call
  end

  attr_reader :legal_aid_application

  def initialize(legal_aid_application)
    @legal_aid_application = legal_aid_application
  end

  def call
    CleanupCapitalAttributes.call(legal_aid_application)
    SaveApplicantMeansAnswers.call(legal_aid_application)
    legal_aid_application.update!(
      provider_step: intended_provider_step,
      completed_at: Time.current
    )
  end

  private

  def intended_provider_step
    Flow::KeyPoint.step_for(
      journey: :providers,
      key_point: :start_after_applicant_completes_means
    )
  end
end
