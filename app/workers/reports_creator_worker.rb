class ReportsCreatorWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(legal_aid_application_id)
    legal_aid_application = LegalAidApplication.find(legal_aid_application_id)
    Reports::ReportsCreator.call(legal_aid_application)
  end
end
