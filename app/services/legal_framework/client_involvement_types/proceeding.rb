module LegalFramework
  module ClientInvolvementTypes
    class Proceeding < LegalFramework::BaseApiCall
      class ClientInvolvementTypeStruct
        attr_reader :ccms_code, :description

        def initialize(cit_hash)
          @ccms_code = cit_hash["ccms_code"]
          @description = update_description(cit_hash["description"]) || cit_hash["description"]
        end

        def update_description(description)
          {
            "Applicant/claimant/petitioner": "Applicant, claimant or petitioner",
            "Defendant/respondent": "Defendant or respondent",
            "Subject of proceedings (child)": "A child subject of the proceeding",
          }[description.to_sym]
        end
      end

      def initialize(ccms_code)
        super()
        @proceeding_code = ccms_code
      end

      def call
        JSON.parse(request.body)["client_involvement_type"].map { |cit_hash| ClientInvolvementTypeStruct.new(cit_hash) }
      end

    private

      def path
        "/client_involvement_types/#{@proceeding_code}"
      end
    end
  end
end
