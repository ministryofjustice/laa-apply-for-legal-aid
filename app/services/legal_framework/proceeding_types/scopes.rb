module LegalFramework
  module ProceedingTypes
    class Scopes < LegalFramework::BaseApiCall
      def self.call(proceeding, emergency)
        new(proceeding, emergency).call
      end

      def initialize(proceeding, emergency)
        super()
        @proceeding = proceeding
        @level_of_service_code = emergency ? proceeding.emergency_level_of_service : proceeding.substantive_level_of_service
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

      def path
        "/proceeding_type_scopes"
      end

      def redis_key
        "lfa/proceeding/#{@proceeding.ccms_code}/df_#{@emergency}/cit_#{@proceeding.client_involvement_type_ccms_code}/los_#{@level_of_service_code}/scopes"
      end
    end
  end
end
