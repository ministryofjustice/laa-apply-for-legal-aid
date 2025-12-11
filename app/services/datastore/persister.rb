module Datastore
  class Persister
    attr_reader :legal_aid_application, :response, :datastore_id

    def initialize(legal_aid_application, response:, datastore_id: nil)
      @legal_aid_application = legal_aid_application
      @response = response
      @datastore_id = datastore_id
    end

    def self.call(legal_aid_application, **)
      new(legal_aid_application, **).call
    end

    def call
      legal_aid_application.update!(datastore_id: datastore_id) if datastore_id

      # Store the datastore response for debugging purposes
      legal_aid_application.datastore_submissions.create!(
        status: response.status,
        body: response.body,
        headers: response.headers,
      )
    end
  end
end
