class ProviderDetailsCreatorWorker
  include Sidekiq::Worker

  def perform(provider_id)
    Provider.find(provider_id).update_details_directly
  end
end
