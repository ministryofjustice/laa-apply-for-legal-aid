module LegalFramework
  module ProceedingTypes
    class All
      PATH = "/proceeding_types/all".freeze

      class ProceedingTypeStruct
        attr_reader :ccms_code, :meaning, :description, :ccms_category_law, :ccms_matter_code, :ccms_matter

        def initialize(pt_hash)
          @ccms_code = pt_hash["ccms_code"]
          @meaning = pt_hash["meaning"]
          @description = pt_hash["description"]
          @ccms_category_law = pt_hash["ccms_category_law"]
          @ccms_matter_code = pt_hash["ccms_matter_code"]
          @ccms_matter = pt_hash["ccms_matter"]
        end
      end

      def self.call
        new.call
      end

      def call
        JSON.parse(request.body).map { |pt_hash| ProceedingTypeStruct.new(pt_hash) }
      end

    private

      def request
        conn.get url
      end

      def conn
        @conn ||= Faraday.new(url:, headers:)
      end

      def url
        "#{Rails.configuration.x.legal_framework_api_host}#{PATH}"
      end

      def headers
        { "Content-Type" => "application/json" }
      end
    end
  end
end
