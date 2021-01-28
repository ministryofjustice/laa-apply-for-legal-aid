require 'rails_helper'

module CFE
  RSpec.describe CreateApplicantService do
    let(:application) { create :legal_aid_application, :with_positive_benefit_check_result, transaction_period_finish_on: Time.zone.today }
    let!(:applicant) { create :applicant, legal_aid_application: application }
    let(:submission) { create :cfe_submission, aasm_state: 'assessment_created', legal_aid_application: application }
    let(:dummy_response) { dummy_response_hash.to_json }
    let(:service) { described_class.new(submission) }

    describe '#cfe_url' do
      it 'contains the submission assessment id' do
        expect(service.cfe_url)
          .to eq "#{Rails.configuration.x.check_financial_eligibility_host}/assessments/#{submission.assessment_id}/applicant"
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

      context 'response received from CFE' do
        describe 'successful post' do
          before do
            stub_request(:post, service.cfe_url)
              .with(body: service.request_body)
              .to_return(body: dummy_response)
          end

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
            expect(history.url).to eq service.cfe_url
            expect(history.http_method).to eq 'POST'
            expect(history.request_payload).to eq service.request_body
            expect(history.http_response_status).to eq 200
            expect(history.response_payload).to eq dummy_response
            expect(history.error_message).to be_nil
          end
        end

        context 'unsuccessful_response_from_CFE' do
          it_behaves_like 'a failed call to CFE'
        end
      end

      describe 'failed calls to CFE' do
        it_behaves_like 'a failed call to CFE', CreateApplicantService, 'applicant'
      end
    end

    def expected_payload_hash
      {
        applicant: {
          date_of_birth: applicant.date_of_birth.strftime('%Y-%m-%d'),
          involvement_type: 'applicant',
          has_partner_opponent: false,
          receives_qualifying_benefit: application.applicant_receives_benefit?
        }
      }
    end

    def dummy_response_hash
      {
        success: true
      }
    end
  end
end
