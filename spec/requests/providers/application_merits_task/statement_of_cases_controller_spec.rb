require "rails_helper"
require "sidekiq/testing"

module Providers
  module ApplicationMeritsTask
    RSpec.describe StatementOfCasesController do
      let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8) }
      let(:provider) { legal_aid_application.provider }
      let(:smtl) { create(:legal_framework_merits_task_list, legal_aid_application:) }

      describe "GET /providers/applications/:legal_aid_application_id/statement_of_case" do
        subject(:get_request) { get providers_legal_aid_application_statement_of_case_path(legal_aid_application) }

        context "when the provider is not authenticated" do
          before { get_request }

          it_behaves_like "a provider not authenticated"
        end

        context "when the provider is authenticated" do
          before do
            create(:statement_of_case, legal_aid_application:, upload: false, typed: true, statement: "prepared statement of case") if create_soc
            login_as provider
            get_request
          end

          context "and no Statement of case exists" do
            let(:create_soc) { false }

            it "returns http success" do
              expect(response).to have_http_status(:ok)
            end
          end

          context "and a Statement of case exists with previous choices" do
            let(:create_soc) { true }

            it "returns http success" do
              expect(response).to have_http_status(:ok)
              expect(response.body).to include(/prepared statement of case/)
            end
          end
        end
      end

      describe "POST /providers/applications/:legal_aid_application_id/statement_of_case" do
        subject(:patch_request) do
          patch(
            providers_legal_aid_application_statement_of_case_path(legal_aid_application),
            params:,
          )
        end

        let(:params) do
          {
            application_merits_task_statement_of_case: {
              upload: [""],
              typed: ["", typed],
              statement:,
            },
          }
        end

        let(:upload) { nil } # multiple choice values need to be arrays
        let(:typed) { true } # multiple choice values need to be arrays
        let(:statement) { "Entered text" }

        before do
          allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
          login_as provider
        end

        it "sets the task to complete" do
          patch_request
          expect(legal_aid_application.legal_framework_merits_task_list.serialized_data).to match(/name: :statement_of_case\n\s+dependencies: \*\d\n\s+state: :complete/)
        end

        it "redirects to the next step" do
          patch_request
          expect(response).to have_http_status(:redirect)
        end

        context "when a previous statement of case file was uploaded" do
          before { create(:statement_of_case, :with_empty_text, :with_original_file_attached, upload: true, legal_aid_application:) }

          it "deletes the previous file" do
            expect { patch_request }.to change(legal_aid_application, :statement_of_case_uploaded?).from(true).to(false)
          end
        end
      end
    end
  end
end
