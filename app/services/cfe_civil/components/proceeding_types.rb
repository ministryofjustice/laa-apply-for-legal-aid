module CFECivil
  module Components
    class ProceedingTypes < BaseDataBlock
      def call
        {
          proceeding_types: proceeding_type_details,
        }.to_json
      end

    private

      def proceedings
        legal_aid_application.proceedings.order(:ccms_code)
      end

      def proceeding_type_details
        proceedings.map { |rec| { ccms_code: rec.ccms_code, client_involvement_type: rec.client_involvement_type_ccms_code } }
      end
    end
  end
end
