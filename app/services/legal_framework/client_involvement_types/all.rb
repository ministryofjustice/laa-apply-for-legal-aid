module LegalFramework
  module ClientInvolvementTypes
    class All < LegalFramework::BaseApiCall
      class ClientInvolvementTypeStruct
        attr_reader :ccms_code, :description

        def initialize(cit_hash)
          @ccms_code = cit_hash["ccms_code"]
          @description = cit_hash["description"]
        end
      end

      def call
        JSON.parse(request.body).map { |cit_hash| ClientInvolvementTypeStruct.new(cit_hash) }
      end

      def path
        "/client_involvement_types"
      end
    end
  end
end
