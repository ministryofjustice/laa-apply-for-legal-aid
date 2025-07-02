module Providers
  class CheckPassportedAnswersController < ProviderBaseController
    include ::DurationLogger
    def show
      @proceeding = legal_aid_application.lead_proceeding
      @applicant = legal_aid_application.applicant
      @address = @applicant.addresses.first
      legal_aid_application.check_passported_answers! unless already_checking_answers?
    end

    def continue
      unless draft_selected? || legal_aid_application.provider_entering_merits?
        redirect_to(problem_index_path) && return unless check_financial_eligibility

        legal_aid_application.complete_passported_means!
      end
      continue_or_draft
    end

    def reset
      legal_aid_application.reset!
      redirect_to back_path
    end

  private

    def already_checking_answers?
      legal_aid_application.checking_passported_answers?
    end

    def check_financial_eligibility
      result = false
      log_duration("CFE Submission :: Total call time for #{legal_aid_application.id}") do
        result = CFECivil::SubmissionBuilder.call(@legal_aid_application)
      end
      result
    end
  end
end
