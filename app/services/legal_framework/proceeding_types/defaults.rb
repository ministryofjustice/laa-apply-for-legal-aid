module LegalFramework
  module ProceedingTypes
    class Defaults
      PATH = "/proceeding_type_defaults".freeze

      def self.call(proceeding)
        new(proceeding).call
      end

      def initialize(proceeding)
        @proceeding = proceeding
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
