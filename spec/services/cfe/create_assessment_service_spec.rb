require 'rails_helper'

module CFE
  RSpec.describe CreateAssessmentService do
    let(:application) { create :legal_aid_application }
    let!(:applicant) { create :applicant, legal_aid_application: application }
    let(:submission) { create :cfe_submission, aasm_state: 'initialised', legal_aid_application: application }
    let(:service) { described_class.new(submission) }
    let(:dummy_response) { dummy_response_hash.to_json }

    before do
      allow(application).to receive(:calculation_date).and_return(Date.today)
    end

    describe '#cfe_url' do
      it 'returns the assessment endpoint' do
        expect(service.cfe_url)
          .to eq "#{Rails.configuration.x.check_financial_eligibility_host}/assessments"
      end
    end

    describe '#request payload' do
      it 'creates the expected payload from the values in the applicant' do
        expect(service.request_body).to eq expected_payload_hash.to_json
      end
    end

    describe '.call' do
      around do |example|
        VCR.turn_off!
        example.run
        VCR.turn_on!
      end

      describe 'successful post' do
        before do
          stub_request(:post, service.cfe_url)
            .with(body: expected_payload_hash.to_json)
            .to_return(body: dummy_response)
        end

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
          expect(history.url).to eq service.cfe_url
          expect(history.http_method).to eq 'POST'
          expect(history.request_payload).to eq expected_payload_hash.to_json
          expect(history.http_response_status).to eq 200
          expect(history.response_payload).to eq dummy_response
          expect(history.error_message).to be_nil
        end
      end

      describe 'failed calls to CFE' do
        it_behaves_like 'a failed call to CFE'
      end
    end

    def expected_payload_hash
      {
        client_reference_id: application.application_ref,
        submission_date: Date.today.strftime('%Y-%m-%d'),
        matter_proceeding_type: 'domestic_abuse'
      }
    end

    def dummy_response_hash
      {
        success: true,
        objects: [
          {
            id: '1b2aa5eb-3763-445e-9407-2397ec3968f6',
            client_reference_id: 'L-XYZ-999'
          }
        ],
        assessment_id: '1b2aa5eb-3763-445e-9407-2397ec3968f6',
        errors: []
      }
    end
  end
end
