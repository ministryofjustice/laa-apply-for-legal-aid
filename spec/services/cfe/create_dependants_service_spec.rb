require 'rails_helper'

module CFE
  RSpec.describe CreateDependantsService do
    let(:application) { create :legal_aid_application, :with_negative_benefit_check_result }
    let(:submission) { create :cfe_submission, aasm_state: 'explicit_remarks_created', legal_aid_application: application }
    let(:service) { described_class.new(submission) }
    let(:dummy_response) { dummy_response_hash.to_json }

    describe '#cfe_url' do
      it 'contains the submission assessment id' do
        expect(service.cfe_url)
          .to eq "#{Rails.configuration.x.check_financial_eligibility_host}/assessments/#{submission.assessment_id}/dependants"
      end
    end

    describe '.call' do
      before do
        stub_request(:post, service.cfe_url).with(body: expected_payload_hash.to_json).to_return(body: dummy_response)
      end

      context 'successful calls' do
        context 'no dependants' do
          describe 'successful calls' do
            let(:expected_payload_hash) { empty_payload }

            it 'updates the submission record from explicit_remarks_created to dependants_created' do
              expect(submission.aasm_state).to eq 'explicit_remarks_created'
              described_class.call(submission)
              expect(submission.aasm_state).to eq 'dependants_created'
            end
          end

          context 'with dependants' do
            let(:expected_payload_hash) { loaded_payload }

            before { create_dependants }

            it 'updates the submission record from explicit_remarks_created to dependants_created' do
              expect(submission.aasm_state).to eq 'explicit_remarks_created'
              described_class.call(submission)
              expect(submission.aasm_state).to eq 'dependants_created'
            end

            it 'creates a submission_history record' do
              expect {
                described_class.call(submission)
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
        end
      end

      context 'failed calls to CFE' do
        let(:expected_payload_hash) { loaded_payload }
        it_behaves_like 'a failed call to CFE'
      end
    end

    def dummy_response_hash
      {
        objects: [
          {
            id: '89449cd5-02cc-487d-a334-cf439aaafebf',
            assessment_id: 'b4e3443c-bdf5-479d-820c-f1dd3213360e',
            date_of_birth: '1987-03-29',
            in_full_time_education: true,
            created_at: '2020-03-27T13:08:21.438Z',
            updated_at: '2020-03-27T13:08:21.438Z',
            relationship: 'adult_relative',
            monthly_income: '1352.55',
            assets_value: '0.0',
            dependant_allowance: '0.0'
          },
          {
            id: 'ee01c68c-f465-4a8e-a292-3f0cb1f2cd2d',
            assessment_id: 'b4e3443c-bdf5-479d-820c-f1dd3213360e',
            date_of_birth: '2001-11-23',
            in_full_time_education: true,
            created_at: '2020-03-27T13:08:21.441Z',
            updated_at: '2020-03-27T13:08:21.441Z',
            relationship: 'child_relative',
            monthly_income: '8665.97',
            assets_value: '0.0',
            dependant_allowance: '0.0'
          }
        ],
        errors: [],
        success: true
      }
    end

    def empty_payload
      {
        dependants: []
      }
    end

    def create_dependants
      create :dependant, :over18,
             number: 1,
             date_of_birth: 19.years.ago,
             relationship: 'adult_relative',
             legal_aid_application: application,
             name: 'Stepriponikas Bonstart',
             monthly_income: 180.0,
             in_full_time_education: false,
             assets_value: 10_000.0
      create :dependant, :under18,
             number: 2,
             relationship: 'child_relative',
             date_of_birth: 10.years.ago,
             legal_aid_application: application,
             name: 'Aztec Bonstart',
             monthly_income: 0.0,
             in_full_time_education: true,
             assets_value: 0.0
    end

    def loaded_payload
      {
        dependants: [
          {
            date_of_birth: 19.years.ago.strftime('%Y-%m-%d'),
            relationship: 'adult_relative',
            monthly_income: '180.0',
            in_full_time_education: false,
            assets_value: '10000.0'
          },
          {
            date_of_birth: 10.years.ago.strftime('%Y-%m-%d'),
            relationship: 'child_relative',
            monthly_income: '0.0',
            in_full_time_education: true,
            assets_value: '0.0'
          }
        ]
      }
    end
  end
end
