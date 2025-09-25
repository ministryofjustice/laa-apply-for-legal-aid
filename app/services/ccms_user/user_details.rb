module CCMSUser
  module UserDetails
    class Silas
      ApiError = Class.new(StandardError)
      UserNotFound = Class.new(StandardError)

      extend Forwardable

      def self.call(silas_id)
        new(silas_id).call
      end

      def_delegators :connection, :get

      def initialize(silas_id)
        @silas_id = silas_id
      end

      def call
        response = request

        if response.success?
          JSON.parse(response.body)
        elsif response.status == 404
          provider = Provider.find_by(silas_id:)
          Rails.logger.info("#{self.class} - No provider details found for #{provider.email}")
          raise UserNotFound, "No CCMS username found for #{provider.email}"
        else
          raise ApiError, "API Call Failed: (#{response.status}) #{response.body}"
        end
      end

    private

      attr_reader :silas_id

      def request
        get("user-details/silas/#{silas_id}")
      end

      def connection
        @connection ||= Connection.instance
      end
    end
  end
end
