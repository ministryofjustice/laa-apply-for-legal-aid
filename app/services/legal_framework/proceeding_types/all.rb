module LegalFramework
  module ProceedingTypes
    class All
      PATH = '/proceeding_types/all'.freeze

      def self.call
        new.call
      end

      def call
        JSON.parse(request.body).map { |pt| OpenStruct.new(pt) }
      end

      private

      def request
        conn.get url
      end

      def conn
        @conn ||= Faraday.new(url: url, headers: headers)
      end

      def url
        "#{Rails.configuration.x.legal_framework_api_host}#{PATH}"
      end

      def headers
        { 'Content-Type' => 'application/json' }
      end
    end
  end
end
