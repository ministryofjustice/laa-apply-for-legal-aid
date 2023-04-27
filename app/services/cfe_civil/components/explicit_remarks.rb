module CFECivil
  module Components
    class ExplicitRemarks < BaseDataBlock
      delegate :policy_disregards, to: :legal_aid_application

      def call
        {
          explicit_remarks: policy_disregard_builder,
        }.to_json
      end

    private

      def policy_disregard_builder
        payload = []
        payload << policy_disregards.as_json if policy_disregards.present?
        payload
      end
    end
  end
end
