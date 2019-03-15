module Citizens
  class IncomeSummaryController < BaseController
    include ApplicationFromSession
    before_action :authenticate_applicant!

    def index
      legal_aid_application
      @bank_transactions = legal_aid_application.bank_transactions
                                                .order(happened_at: :desc)
                                                .by_type
    end
  end
end
