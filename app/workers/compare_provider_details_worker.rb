class CompareProviderDetailsWorker
  # NOTE: This is intended as a temporary class while we switch from CCMS Provider Details API
  # to the new Provider Details API.
  # Once that change over is complete, the aim is that this can be removed.
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options retry: false

  def perform(provider_id)
    PDA::CompareProviderDetails.call(provider_id)
  end
end
