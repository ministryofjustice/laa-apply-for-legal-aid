module Flow
  class FlowSteps
    def self.urls
      Rails.application.routes.url_helpers
    end
  end
end
