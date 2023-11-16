module Flow
  module Steps
    def self.urls
      Rails.application.routes.url_helpers
    end

    Step = Struct.new(:path, :forward, :check_answers)
  end
end
