module Citizens
  class IncomeSummaryController < BaseController
    include ApplicationFromSession
    before_action :authenticate_applicant!

    def index
      legal_aid_application
      @bank_transactions = legal_aid_application.bank_transactions.by_type
    end
  end
end
