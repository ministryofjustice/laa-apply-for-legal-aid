require 'rails_helper'

module CFE
  RSpec.describe CreateApplicantService do
    let(:application) { create :legal_aid_application }
    let!(:applicant) { create :applicant, legal_aid_application: application }
    let(:submission) { create :cfe_submission, aasm_state: 'assessment_created', legal_aid_application: application }
    let(:expected_payload) { expected_payload_hash.to_json }
    let(:expected_response) { expected_response_hash.to_json }
    let(:cfe_host) { Rails.configuration.x.check_finanical_eligibility_host }
    let(:cfe_url) { "#{cfe_host}/assessments/#{submission.assessment_id}/applicant" }

    context 'response received from CFE' do
      before do
        allow(application).to receive(:applicant_receives_benefit?).and_return(true)
        allow(application).to receive(:calculation_date).and_return(Date.today)
        allow_any_instance_of(described_class).to receive(:request_body).and_return(expected_payload)
      end

      describe 'successful post' do
        before { stub_request(:post, cfe_url).with(body: expected_payload).to_return(body: expected_response) }

        it 'updates the submission record from assessment_created to applicant_created' do
          expect(submission.aasm_state).to eq 'assessment_created'
          CreateApplicantService.call(submission)
          expect(submission.aasm_state).to eq 'applicant_created'
        end

        it 'creates a submission_history record' do
          expect {
            CreateApplicantService.call(submission)
          }.to change { submission.submission_histories.count }.by 1
          history = CFE::SubmissionHistory.last
          expect(history.submission_id).to eq submission.id
          expect(history.url).to eq "http://localhost:3001/assessments/#{submission.assessment_id}/applicant"
          expect(history.http_method).to eq 'POST'
          expect(history.request_payload).to eq expected_payload
          expect(history.http_response_status).to eq 200
          expect(history.response_payload).to eq expected_response
          expect(history.error_message).to be_nil
        end
      end

      context 'unsuccessful_response_from_CFE' do
        it_behaves_like 'a failed call to CFE'
      end
    end

    def expected_payload_hash
      {
        applicant: {
          date_of_birth: applicant.date_of_birth.strftime('%Y-%m-%d'),
          involvement_type: 'applicant',
          has_partner_opponent: false,
          receives_qualifying_benefit: true
        }
      }
    end

    def expected_response_hash # rubocop:disable Metrics/MethodLength
      {
        objects: [
          {
            id: 'b464458d-cf3d-4860-a1cc-a1838c2babd9',
            assessment_id: '3e1eb9db-f639-4fc2-81a7-0d12db4a2faf',
            date_of_birth: '1999-09-11',
            involvement_type: 'applicant',
            has_partner_opponent: false,
            receives_qualifying_benefit: true,
            created_at: '2019-09-11T14:15:58.641Z',
            updated_at: '2019-09-11T14:15:58.641Z'
          }
        ],
        errors: [],
        success: true
      }
    end
  end
end
