class BankTransactionsAnalyserWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options retry: false

  attr_reader :legal_aid_application_id

  def perform(legal_aid_application_id)
    @legal_aid_application_id = legal_aid_application_id
    StateBenefitAnalyserService.call(legal_aid_application)
  end

  def legal_aid_application
    LegalAidApplication.find(legal_aid_application_id)
  end
end
