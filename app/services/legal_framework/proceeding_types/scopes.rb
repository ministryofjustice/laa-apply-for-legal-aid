module LegalFramework
  module ProceedingTypes
    class Scopes
      PATH = "/proceeding_type_scopes".freeze

      def self.call(proceeding, level_of_service_code)
        new(proceeding, level_of_service_code).call
      end

      def initialize(proceeding, level_of_service_code)
        @proceeding = proceeding
        @level_of_service_code = level_of_service_code
      end

      def call
        request.body
      end

    private

      def request_body
        {
          proceeding_type_ccms_code: @proceeding.ccms_code,
          delegated_functions_used: @proceeding.used_delegated_functions,
          client_involvement_type: @proceeding.client_involvement_type_ccms_code,
          level_of_service_code: @level_of_service_code,
        }.to_json
      end

      def request
        conn.post do |request|
          request.url url
          request.headers["Content-Type"] = "application/json"
          request.body = request_body
        end
      end

      def conn
        @conn ||= Faraday.new(url:, headers:)
      end

      def url
        "#{Rails.configuration.x.legal_framework_api_host}#{PATH}"
      end

      def headers
        {
          "Content-Type" => "application/json",
        }
      end
    end
  end
end
