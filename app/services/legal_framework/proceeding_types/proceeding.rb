module LegalFramework
  module ProceedingTypes
    class Proceeding
      PATH = '/proceeding_types/'.freeze

      def self.call(ccms_code)
        new(ccms_code).call
      end

      def initialize(ccms_code)
        @ccms_code = ccms_code
      end

      def call
        OpenStruct.new(JSON.parse(request.body))
      end

      private

      def request
        conn.get url
      end

      def conn
        @conn ||= Faraday.new(url: url, headers: headers)
      end

      def url
        "#{Rails.configuration.x.legal_framework_api_host}#{PATH}#{@ccms_code}"
      end

      def headers
        { 'Content-Type' => 'application/json' }
      end
    end
  end
end
