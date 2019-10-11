module Flow
  class FlowSteps
    extend OmniauthPathHelper

    def self.urls
      Rails.application.routes.url_helpers
    end
  end
end
