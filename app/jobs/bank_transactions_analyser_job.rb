class BankTransactionsAnalyserJob < ApplicationJob
  def perform(legal_aid_application)
    Banking::BankTransactionBalanceCalculator.call(legal_aid_application)
    Banking::BankTransactionsTrimmer.call(legal_aid_application)
    Banking::StateBenefitAnalyserService.call(legal_aid_application)
    legal_aid_application.complete_bank_transaction_analysis!
    ProviderEmailService.new(legal_aid_application).send_email if legal_aid_application.provider_assessing_means?
  end
end
