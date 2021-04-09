require 'rails_helper'

module LegalFramework
  RSpec.describe MeritsTasksRetrieverService do
    let(:application) { create :legal_aid_application, :with_proceeding_types }
    let(:submission) { create :legal_framework_submission, legal_aid_application: application }
    let(:dummy_response) { dummy_response_hash.to_json }
    let(:service) { described_class.new(submission) }
    let(:api_url) { "#{Rails.configuration.x.legal_framework_api_host}/merits_tasks" }

    describe '#url' do
      it 'contains correct url' do
        expect(service.legal_framework_url).to eq api_url
      end
    end

    describe '#request_body' do
      it 'creates the expected payload from the application proceeding types' do
        expect(service.request_body).to eq expected_payload_hash.to_json
      end
    end

    describe '.call' do
      around do |example|
        VCR.turn_off!
        example.run
        VCR.turn_on!
      end

      context 'response received from Legal Framework API' do
        describe 'successful post' do
          before do
            stub_request(:post, service.legal_framework_url)
              .with(body: service.request_body)
              .to_return(body: dummy_response)
          end

          it 'returns a list of merits tasks' do
            outcome = service.call
            expect(outcome).to eq dummy_response_hash
          end

          it 'stores a submission history record' do
            expect { service.call }.to change { LegalFramework::SubmissionHistory.count }
          end
        end
      end

      context 'unsuccessful_response_from_LegalFrameworkAPI' do
        it_behaves_like 'a failed call to LegalFrameworkAPI'
      end
    end

    def expected_payload_hash
      proceeding_types = application.proceeding_types.first
      {
        request_id: submission.id,
        proceeding_types: [proceeding_types.ccms_code]
      }
    end

    def dummy_response_hash
      {
        request_id: submission.id,
        application: {
          tasks: {
            incident_details: [],
            opponent_details: [],
            application_children: []
          }
        },
        proceeding_types: [
          {
            ccms_code: application.proceeding_types.first.ccms_code,
            tasks: {
              chances_of_success: [] # the merits tasks for this one proceeding type, and any dependencies
            }
          }
        ]
      }
    end
  end
end
