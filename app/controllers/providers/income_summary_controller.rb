module Providers
  class IncomeSummaryController < ProviderBaseController
    before_action :authorize_legal_aid_application

    def index
      @bank_transactions = @legal_aid_application.bank_transactions
                                                 .credit
                                                 .order(happened_at: :desc)
                                                 .by_type
    end

    def create
      continue_or_draft
    end

    private

    def authorize_legal_aid_application
      authorize @legal_aid_application
    end
  end
end
