module Dashboard
  class ProviderDataJob < ActiveJob::Base
    def perform(provider)
      Dashboard::SingleObject::ProviderData.new(provider).run
    end
  end
end
