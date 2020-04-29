module Providers
  class IncomeSummaryController < ProviderBaseController
    def index
      @bank_transactions = bank_transactions
    end

    def create
      return continue_or_draft if draft_selected?

      if uncategorized_transactions?
        @bank_transactions = bank_transactions
        render :index
      else
        go_forward
      end
    end

    private

    def uncategorized_transactions?
      @legal_aid_application.uncategorised_bank_transactions?
    end

    def bank_transactions
      @legal_aid_application.bank_transactions
                            .credit
                            .order(happened_at: :desc)
                            .by_type
    end
  end
end
