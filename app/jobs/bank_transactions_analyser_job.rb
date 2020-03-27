class BankTransactionsAnalyserJob < ActiveJob::Base
  def perform(legal_aid_application)
    legal_aid_application.analyse_bank_transactions!
  end
end
