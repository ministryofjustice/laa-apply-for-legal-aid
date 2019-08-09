module Providers
  class MeansSummariesController < ProviderBaseController
    def show
      authorize legal_aid_application
      legal_aid_application.set_transaction_period
      legal_aid_application.provider_check_citizens_means_answers! unless legal_aid_application.provider_checking_citizens_means_answers?
    end

    def update
      authorize legal_aid_application
      legal_aid_application.provider_checked_citizens_means_answers! unless draft_selected? || legal_aid_application.provider_checked_citizens_means_answers?
      continue_or_draft
    end
  end
end
