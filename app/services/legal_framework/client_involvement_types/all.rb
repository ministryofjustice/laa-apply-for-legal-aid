module LegalFramework
  module ClientInvolvementTypes
    class All < LegalFramework::BaseApiCall
      class ClientInvolvementTypeStruct
        attr_reader :ccms_code, :description

        def initialize(cit_hash)
          @ccms_code = cit_hash["ccms_code"]
          @description = update_description(@ccms_code) || cit_hash["description"]
        end

        def update_description(code)
          {
            A: "Applicant, claimant or petitioner",
            D: "Defendant or respondent",
            W: "A child subject of the proceeding",
          }[code.to_sym]
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
