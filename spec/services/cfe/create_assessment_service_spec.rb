require 'rails_helper'

module CFE
  RSpec.describe CreateAssessmentService do
    let(:application) { create :legal_aid_application }
    let!(:applicant) { create :applicant, legal_aid_application: application }
    let(:submission) { create :cfe_submission, aasm_state: 'initialised', legal_aid_application: application }
    let(:expected_payload) { expected_payload_hash.to_json }
    let(:expected_response) { expected_response_hash.to_json }
    let(:cfe_host) { Rails.configuration.x.check_finanical_eligibility_host }
    let(:cfe_url) { "#{cfe_host}/assessments" }

    before do
      allow(application).to receive(:calculation_date).and_return(Date.today)
      allow_any_instance_of(described_class).to receive(:request_body).and_return(expected_payload)
    end

    describe 'successful post' do
      before { stub_request(:post, cfe_url).with(body: expected_payload).to_return(body: expected_response) }

      it 'updates the submission record from initialised to assessment created' do
        expect(submission.aasm_state).to eq 'initialised'
        CreateAssessmentService.call(submission)
        expect(submission.aasm_state).to eq 'assessment_created'
      end

      it 'creates a submission_history record' do
        expect {
          CreateAssessmentService.call(submission)
        }.to change { submission.submission_histories.count }.by 1
        history = CFE::SubmissionHistory.last
        expect(history.submission_id).to eq submission.id
        expect(history.url).to eq cfe_url
        expect(history.http_method).to eq 'POST'
        expect(history.request_payload).to eq expected_payload
        expect(history.http_response_status).to eq 200
        expect(history.response_payload).to eq expected_response
        expect(history.error_message).to be_nil
      end
    end

    describe 'failed calls to CFE' do
      it_behaves_like 'a failed call to CFE'
    end

    def expected_payload_hash
      {
        client_reference_id: application.application_ref,
        submission_date: Date.today. strftime('%Y-%m-%d'),
        matter_proceeding_type: 'domestic_abuse'
      }
    end

    def expected_response_hash # rubocop:disable Metrics/MethodLength
      {
        success: true,
        objects: [
          {
            id: '1b2aa5eb-3763-445e-9407-2397ec3968f6',
            client_reference_id: 'L-XYZ-999',
            remote_ip: {
              family: 2,
              addr: 2_130_706_433,
              mask_addr: 4_294_967_295
            },
            created_at: '2019-09-11T14 =>15 =>58.672Z',
            updated_at: '2019-09-11T14 =>15 =>58.672Z',
            submission_date: '2019-06-06',
            matter_proceeding_type: 'domestic_abuse',
            assessment_result: 'pending'
          }
        ],
        errors: []
      }
    end
  end
end
