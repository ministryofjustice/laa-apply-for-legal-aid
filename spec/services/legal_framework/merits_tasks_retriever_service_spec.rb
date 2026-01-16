require "rails_helper"

module LegalFramework
  RSpec.describe MeritsTasksRetrieverService do
    let(:application) { create(:legal_aid_application, :with_proceedings) }
    let(:submission) { create(:legal_framework_submission, legal_aid_application: application) }
    let(:dummy_response) { dummy_response_hash.to_json }
    let(:service) { described_class.new(submission) }
    let(:loop_api_url) { "#{Rails.configuration.x.legal_framework_api_host}/civil_merits_questions" }

    let(:expected_payload_hash) do
      {
        request_id: submission.id,
        proceedings: [
          {
            ccms_code: application.proceedings.first.ccms_code,
            delegated_functions_used: application.proceedings.first.used_delegated_functions,
            client_involvement_type: application.proceedings.first.client_involvement_type_ccms_code,
            substantive_level_of_service: application.proceedings.first.substantive_level_of_service,
          },
        ],
      }
    end
    let(:dummy_response_hash) do
      {
        request_id: submission.id,
        application: {
          tasks: {
            incident_details: [],
            opponent_details: [],
            application_children: [],
            client_denial_of_allegation: [],
            client_offer_of_undertakings: [],
          },
        },
        proceedings: [
          {
            ccms_code: application.proceedings.first.ccms_code,
            tasks: {
              chances_of_success: [], # the merits tasks for this one proceeding type, and any dependencies
            },
          },
        ],
      }
    end

    describe "#url" do
      it "contains correct url" do
        expect(service.legal_framework_url).to eq loop_api_url
      end
    end

    describe "#request_body" do
      it "creates the expected payload from the application proceeding types" do
        expect(service.request_body).to eq expected_payload_hash.to_json
      end
    end

    describe ".call" do
      around do |example|
        VCR.turned_off { example.run }
      end

      context "when a response is received from Legal Framework API" do
        describe "successful post" do
          before do
            stub_request(:post, service.legal_framework_url)
              .with(body: service.request_body)
              .to_return(body: dummy_response)
          end

          it "returns a list of merits tasks" do
            outcome = service.call
            expect(outcome).to eq dummy_response_hash
          end

          it "stores a submission history record" do
            expect { service.call }.to change(LegalFramework::SubmissionHistory, :count)
          end
        end
      end

      context "when an unsuccessful response is received from the Legal Framework API" do
        it_behaves_like "a failed call to LegalFrameworkAPI"
      end
    end
  end
end
