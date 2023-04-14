module CFECivil
  module Components
    class Assessment < BaseDataBlock
      def call
        {
          assessment: {
            client_reference_id: legal_aid_application.application_ref,
            submission_date: legal_aid_application.calculation_date.strftime("%Y-%m-%d"),
          },
        }.to_json
      end
    end
  end
end
