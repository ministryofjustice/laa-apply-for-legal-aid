module Flow
  module Steps
    module ProviderCapital
      PaymentsToReviewStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_payments_to_review_path(application) },
        forward: ->(application) { application.passported? ? :check_passported_answers : :check_capital_answers },
        check_answers: ->(application) { application.provider_checking_or_checked_citizens_means_answers? ? :check_capital_answers : :check_passported_answers },
      )
    end
  end
end
