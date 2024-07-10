require "rails_helper"

module Providers
  module ProceedingMeritsTask
    RSpec.describe IsClientChildSubjectController do
      let(:smtl) { create(:legal_framework_merits_task_list, :pb003_pb059, legal_aid_application:) }
      let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[pb003 pb059]) }
      let(:proceeding) { legal_aid_application.proceedings.find_by(ccms_code: "PB003") }
      let(:login) { login_as legal_aid_application.provider }

      before do
        allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
        login
      end

      describe "GET /providers/merits_task_list/:id/is_client_child_subject" do
        subject(:get_request) { get providers_merits_task_list_is_client_child_subject_path(proceeding) }

        it "renders successfully" do
          get_request
          expect(response).to have_http_status(:ok)
        end

        context "when the provider is not authenticated" do
          let(:login) { nil }

          before { get_request }

          it_behaves_like "a provider not authenticated"
        end
      end
    end
  end
end
