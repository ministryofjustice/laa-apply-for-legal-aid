module Providers
  class ClientCompletedMeansController < ProviderBaseController
    def show
      define_action_list
    end

    def update
      continue_or_draft
    end

  private

    def define_action_list
      @action_list = %w[sort_transactions dependants capital]
      @action_list.prepend("review_employment") if employed_journey?
    end

    def employed_journey?
      @legal_aid_application.applicant.employed? || @legal_aid_application.employment_payments.any?
    end
  end
end
