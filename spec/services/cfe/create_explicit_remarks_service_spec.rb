require 'rails_helper'

module CFE
  RSpec.describe CreateExplicitRemarksService do
    let(:application) { create :legal_aid_application, :with_negative_benefit_check_result, :with_single_policy_disregard }
    let(:submission) { create :cfe_submission, aasm_state: 'properties_created', legal_aid_application: application }
    let(:service) { described_class.new(submission) }

    describe '#cfe_url' do
      it 'contains the submission assessment id' do
        expect(service.cfe_url)
          .to eq "#{Rails.configuration.x.check_financial_eligibility_host}/assessments/#{submission.assessment_id}/explicit_remarks"
      end
    end

    describe '#request_body' do
      it 'is as expected' do
        service = described_class.new(submission)
        expect(service.request_body).to eq expected_payload
      end
    end

    describe '.call' do
      before do
        stub_request(:post, service.cfe_url).with(body: expected_payload).to_return(body: dummy_response)
      end

      it 'formats the payload and calls CFE API' do
        described_class.call(submission)
      end

      it 'progresses the submission state' do
        described_class.call(submission)
        expect(submission.reload.aasm_state).to eq 'explicit_remarks_created'
      end
    end

    def expected_payload
      {
        explicit_remarks: [
          {
            category: 'policy_disregards',
            details: ['vaccine_damage_payments']
          }
        ]
      }.to_json
    end

    def dummy_response
      {
        success: true,
        errors: []
      }.to_json
    end
  end
end
