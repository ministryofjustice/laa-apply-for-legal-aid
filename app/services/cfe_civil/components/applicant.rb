module CFECivil
  module Components
    class Applicant < BaseDataBlock
      delegate :applicant, to: :legal_aid_application

      def call
        {
          applicant: {
            date_of_birth: applicant.date_of_birth.strftime("%Y-%m-%d"),
            employed: applicant.employed,
            involvement_type: "applicant",
            has_partner_opponent: false,
            receives_qualifying_benefit: legal_aid_application.applicant_receives_benefit?,
          },
        }.to_json
      end
    end
  end
end
