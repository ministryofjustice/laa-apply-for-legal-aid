class ImportBankDataWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options retry: false

  attr_reader :legal_aid_application_id

  def perform(legal_aid_application_id)
    @legal_aid_application_id = legal_aid_application_id
    command = TrueLayer::BankDataImportService.call(
      legal_aid_application: legal_aid_application
    )
    store errors: command.errors.to_a.flatten.to_json unless command.success?
  end

  def legal_aid_application
    LegalAidApplication.find(legal_aid_application_id)
  end
end
