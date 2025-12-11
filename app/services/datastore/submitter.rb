module Datastore
  class Submitter
    extend Forwardable

    ApiError = Class.new(StandardError)

    attr_reader :legal_aid_application, :connection, :persister

    def_delegators :connection, :post

    def initialize(legal_aid_application, connection: Datastore::Connection.new, persister: Datastore::Persister)
      @legal_aid_application = legal_aid_application
      @connection = connection
      @persister = persister
    end

    def self.call(legal_aid_application, **)
      new(legal_aid_application, **).call
    end

    def call
      persister.call(legal_aid_application, response: response, datastore_id: datastore_id) if persister

      if response.success?
        datastore_id
      else
        raise ApiError, "Datastore Submission Failed: status #{response.status}, body #{response.body.presence || 'nil'}"
      end
    end

  private

    def response
      @response ||= connection.post("applications", payload.to_json)
    end

    def datastore_id
      @datastore_id ||= response.headers["location"]&.split("/")&.last
    end

    def payload
      PayloadGenerator.call(legal_aid_application)
    end
  end
end
