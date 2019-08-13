module Providers
  class IncomeSummaryController < ProviderBaseController
    def index
      @bank_transactions = @legal_aid_application.bank_transactions
                                                 .credit
                                                 .order(happened_at: :desc)
                                                 .by_type
    end

    def create
      continue_or_draft
    end
  end
end
