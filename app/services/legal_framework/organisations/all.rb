module LegalFramework
  module Organisations
    class All < BaseApiCall
      class OrganisationStruct
        attr_reader :name, :ccms_type_code, :ccms_type_text, :ccms_opponent_id

        def initialize(org_hash)
          @name = org_hash["name"]
          @ccms_type_code = org_hash["ccms_type_code"]
          @ccms_type_text = org_hash["ccms_type_text"]
          @ccms_opponent_id = org_hash["ccms_opponent_id"]
        end
      end

      def call
        JSON.parse(cached_response).map { |org_hash| OrganisationStruct.new(org_hash) }
      end

      def path
        "/organisation_searches/all"
      end

    private

      def cached_response
        read_or_store_values { request.body }
      end

      def redis_key
        "lfa/organisations"
      end
    end
  end
end
