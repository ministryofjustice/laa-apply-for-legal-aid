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
        JSON.parse(request.body).map { |ot_hash| OrganisationTypeStruct.new(ot_hash) }
      end

      def path
        "/organisation_types/all"
      end
    end
  end
end
