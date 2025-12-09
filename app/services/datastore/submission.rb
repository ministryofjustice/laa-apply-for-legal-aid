module Datastore
  class Submission
    extend Forwardable

    ApiError = Class.new(StandardError)

    attr_reader :legal_aid_application, :connection

    def_delegators :connection, :post

    def initialize(legal_aid_application, connection: Datastore::Connection.new)
      @legal_aid_application = legal_aid_application
      @connection = connection
    end

    def self.call(legal_aid_application, connection: Datastore::Connection.new)
      new(legal_aid_application, connection:).call
    end

    def call
      if response.success?
        datastore_id_from_response
      else
        raise ApiError, "Datastore Submission Failed: status #{response.status}, body #{response.body.presence || 'nil'}"
      end
    end

  private

    def response
      @response ||= connection.post("applications", payload.to_json)
    end

    def datastore_id_from_response
      response.headers["location"]&.split("/")&.last
    end

    def payload
      Datastore::PayloadGenerator.call(legal_aid_application)
    end
  end
end
