module LegalFramework
  module ProceedingTypes
    class Defaults < LegalFramework::BaseApiCall
      def self.call(proceeding, emergency)
        new(proceeding, emergency).call
      end

      def initialize(proceeding, emergency)
        super()
        @proceeding = proceeding
        @emergency = emergency
      end

      def call
        read_or_store_values { request.body }
      end

    private

      def request_body
        {
          proceeding_type_ccms_code: @proceeding.ccms_code,
          delegated_functions_used: @emergency,
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

      def path
        "/proceeding_type_defaults"
      end

      def redis_key
        "lfa/proceeding/#{@proceeding.ccms_code}/df_#{@emergency}/cit_#{@proceeding.client_involvement_type_ccms_code}"
      end
    end
  end
end
