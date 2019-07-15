class ProviderDetailsCreatorWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(provider_id)
    Provider.find(provider_id).update_details_directly
  end
end
