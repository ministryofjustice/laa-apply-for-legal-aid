require "rails_helper"

RSpec.describe Providers::ApplicationMeritsTask::SecondAppealsController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_public_law_family_appeal) }
  let(:provider) { legal_aid_application.provider }
  # let(:next_flow_step) { flow_forward_path }
  let(:smtl) { create(:legal_framework_merits_task_list, :pbm01a_as_applicant, legal_aid_application:) }

  before { login_as provider }

  describe "GET /providers/:application_id/second_appeal" do
    subject(:get_second_appeal) { get providers_legal_aid_application_second_appeal_path(legal_aid_application) }

    before { get_second_appeal }

    it "returns http success" do
      expect(response).to have_http_status(:ok)
    end

    it "displays the page" do
      expect(page)
        .to have_title("Is this a second appeal?")
        .and have_css("h1", text: "Is this a second appeal?")
    end
  end

  describe "PATCH /providers/:application_id/second_appeal" do
    subject(:post_second_appeal) { patch providers_legal_aid_application_second_appeal_path(legal_aid_application), params: }

    before do
      allow(LegalFramework::MeritsTasksService)
        .to receive(:call).with(legal_aid_application).and_return(smtl)
    end

    context "when the user chooses yes" do
      let(:params) { { legal_aid_application: { second_appeal: "true" } } }

      it "updates the record" do
        expect { post_second_appeal }
          .to change { legal_aid_application.reload.second_appeal }.from(nil).to(true)
      end

      it "redirects to the next page", skip: "TODO: AP-5530" do
        post_second_appeal
        expect(response).to redirect_to(:second_appeal_court)
      end
    end

    context "when the user chooses no" do
      let(:params) { { legal_aid_application: { second_appeal: false } } }

      it "updates the record" do
        expect { post_second_appeal }
          .to change { legal_aid_application.reload.second_appeal }.from(nil).to(false)
      end

      it "redirects to the next page", skip: "TODO: AP-5530" do
        post_second_appeal
        expect(response).to redirect_to(:original_judge_level)
      end
    end

    context "when the user chooses nothing" do
      let(:params) { {} }

      it "stays on the page if there is a validation error" do
        post_second_appeal

        expect(response).to have_http_status(:ok)

        within(".govuk-error-summary") do
          expect(page).to have_content("Select yes if this is a second appeal")
        end
      end
    end

    context "when the form submitted with Save as draft button" do
      context "with a yes or no chosen" do
        let(:params) { { legal_aid_application: { second_appeal: false }, draft_button: "Save and come back later" } }

        it "updates the application" do
          expect { post_second_appeal }
            .to change { legal_aid_application.reload.second_appeal }.from(nil).to(false)
        end

        it "redirects to the list of applications" do
          post_second_appeal
          expect(response).to redirect_to(submitted_providers_legal_aid_applications_path)
        end
      end

      context "with no answer chosen" do
        let(:params) { { draft_button: "Save and come back later" } }

        it "does not change application answer" do
          expect { post_second_appeal }
            .not_to change { legal_aid_application.reload.second_appeal }.from(nil)
        end

        it "redirects to the list of applications" do
          post_second_appeal
          expect(response).to redirect_to(submitted_providers_legal_aid_applications_path)
        end
      end
    end
  end
end
