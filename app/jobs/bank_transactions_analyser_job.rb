class BankTransactionsAnalyserJob < ActiveJob::Base
  def perform(legal_aid_application)
    StateBenefitAnalyserService.call(legal_aid_application)
    legal_aid_application.complete_bank_transaction_analysis!
  end
end
