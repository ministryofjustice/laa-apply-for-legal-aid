class BankTransactionsAnalyserJob < ActiveJob::Base

  def self.perform(legal_aid_application)
    legal_aid_application.state = 'provider_assessing_means'
  end
end
