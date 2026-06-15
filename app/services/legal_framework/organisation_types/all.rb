module LegalFramework
  module OrganisationTypes
    class All < LegalFramework::BaseApiCall
      class OrganisationTypeStruct
        attr_reader :ccms_code, :description

        def initialize(organisation_type_hash)
          @ccms_code = organisation_type_hash["ccms_code"]
          @description = organisation_type_hash["description"]
        end
      end

      def call
        JSON.parse(cached_response).map { |ot_hash| OrganisationTypeStruct.new(ot_hash) }
      end

      def cached_response
        read_or_store_values { request.body }
      end

      def path
        "/organisation_types/all"
      end

      def redis_key
        "lfa/organisation_types"
      end
    end
  end
end
