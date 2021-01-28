module Citizens
  class CheckAnswersController < CitizenBaseController
    def index
      legal_aid_application.check_citizen_answers! unless legal_aid_application.checking_citizen_answers?
    end

    def continue
      record_acceptance
      legal_aid_application.complete_non_passported_means! unless legal_aid_application.provider_assessing_means?
      send_emails
      CitizenCompleteMeansJob.perform_later(legal_aid_application.id)
      current_applicant.forget_me!
      go_forward
    end

    def reset
      legal_aid_application.reset!
      redirect_to back_path
    end

    private

    def record_acceptance
      return if legal_aid_application.declaration_accepted_at?

      legal_aid_application.update!(declaration_accepted_at: Time.current)
    end

    def send_emails
      CitizenCompletionEmailService.new(legal_aid_application).send_email
    end
  end
end
