module Datastore
  class MockDatastoreToken
    attr_reader :access_token

    def initialize
      @access_token = Rails.configuration.x.data_access_api.mock_bearer_token
    end
  end
end
