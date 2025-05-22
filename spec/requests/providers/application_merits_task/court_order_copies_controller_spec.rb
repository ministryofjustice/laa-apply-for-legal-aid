require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe DateClientToldIncidentsController do
      let(:legal_aid_application) { create(:legal_aid_application, :with_public_law_family_prohibited_steps_order) }
      let(:login_provider) { login_as legal_aid_application.provider }
      let(:smtl) { create(:legal_framework_merits_task_list, :pbm16_as_defendant, legal_aid_application:) }

      describe "GET /providers/applications/:legal_aid_application_id/court_order" do
        subject(:get_request) do
          get providers_legal_aid_application_court_order_copy_path(legal_aid_application)
        end

        before do
          login_provider
          get_request
        end

        it "renders successfully" do
          expect(response).to have_http_status(:ok)
        end

        context "when not authenticated" do
          let(:login_provider) { nil }

          it_behaves_like "a provider not authenticated"
        end

        context "when there is not PLF court order evidence already uploaded" do
          it "does not display the banner" do
            expect(response.body).to have_no_text("Any related files you uploaded will be deleted if you change your answer")
          end
        end

        context "when there is PLF court order evidence already uploaded" do
          let(:legal_aid_application) { create(:legal_aid_application, :with_public_law_family_prohibited_steps_order, :with_plf_court_order_attached) }

          it "does display the banner" do
            expect(response.body).to have_text("Any related files you uploaded will be deleted if you change your answer")
          end
        end
      end

      describe "PATCH /providers/applications/:legal_aid_application_id/court_order" do
        subject(:patch_request) do
          patch(
            providers_legal_aid_application_court_order_copy_path(legal_aid_application),
            params:,
          )
        end

        before do
          allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
          login_provider
          patch_request
        end

        context "when not authenticated" do
          let(:login_provider) { nil }
          let(:params) { { legal_aid_application: { plf_court_order: true } } }

          before { patch_request }

          it_behaves_like "a provider not authenticated"
        end

        context "when the user chooses yes" do
          let(:params) { { legal_aid_application: { plf_court_order: true } } }

          it "updates the record" do
            expect(legal_aid_application.reload.plf_court_order).to be(true)
          end

          it "redirects to the next page" do
            expect(response).to redirect_to(flow_forward_path)
          end

          context "when there is PLF court order evidence already uploaded" do
            let(:legal_aid_application) { create(:legal_aid_application, :with_public_law_family_prohibited_steps_order, :with_plf_court_order_attached) }

            it "does not delete the uploaded evidence" do
              expect(legal_aid_application.attachments.plf_court_order.first).not_to be_nil
            end
          end
        end

        context "when the user chooses no" do
          let(:params) { { legal_aid_application: { plf_court_order: false } } }

          it "updates the record" do
            expect(legal_aid_application.reload.plf_court_order).to be(false)
          end

          it "redirects to the next page" do
            expect(response).to redirect_to(flow_forward_path)
          end

          context "when there is PLF court order evidence already uploaded" do
            let(:legal_aid_application) { create(:legal_aid_application, :with_public_law_family_prohibited_steps_order, :with_plf_court_order_attached) }

            it "deletes the uploaded evidence" do
              expect(legal_aid_application.attachments.plf_court_order.first).to be_nil
            end
          end
        end

        context "when the user chooses nothing" do
          let(:params) { { legal_aid_application: { plf_court_order: nil } } }

          it "stays on the page if there is a validation error" do
            expect(response).to have_http_status(:ok)
            expect(unescaped_response_body).to include(I18n.t("activemodel.errors.models.legal_aid_application.attributes.plf_court_order.inclusion"))
          end
        end

        context "when the form submitted with Save as draft button" do
          let(:params) { { legal_aid_application: { plf_court_order: false }, draft_button: "Save and come back later" } }

          it "redirects to the list of applications" do
            expect(response).to redirect_to in_progress_providers_legal_aid_applications_path
          end
        end

        context "when checking merits answers" do
          let(:legal_aid_application) { create(:legal_aid_application, :with_public_law_family_prohibited_steps_order, :checking_merits_answers) }

          context "when the user chooses yes" do
            let(:params) { { legal_aid_application: { plf_court_order: true } } }

            it "redirects to the upload supporting evidence page" do
              expect(response).to redirect_to(providers_legal_aid_application_uploaded_evidence_collection_path)
            end
          end

          context "when the user chooses no" do
            let(:params) { { legal_aid_application: { plf_court_order: false } } }

            it "redirects to the check merits answers page" do
              expect(response).to redirect_to(providers_legal_aid_application_check_merits_answers_path)
            end
          end
        end
      end
    end
  end
end
