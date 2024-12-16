require "rails_helper"

RSpec.describe Providers::ApplicationMeritsTask::SecondAppealCourtTypesController do
  let(:legal_aid_application) do
    create(:legal_aid_application,
           :with_public_law_family_appeal,
           appeal: create(:appeal,
                          second_appeal: false,
                          court_type: nil))
  end

  let(:provider) { legal_aid_application.provider }
  let(:next_flow_step) { flow_forward_path }
  let(:smtl) { create(:legal_framework_merits_task_list, :pbm01a_as_applicant, legal_aid_application:) }

  before { login_as provider }

  context "when not authenticated" do
    before { logout }

    context "when GET /providers/:application_id/second_appeal_court_type" do
      before do
        get providers_legal_aid_application_second_appeal_court_type_path(legal_aid_application)
      end

      it_behaves_like "a provider not authenticated"
    end

    context "when PATCH /providers/:application_id/second_appeal_court_type" do
      before do
        patch providers_legal_aid_application_second_appeal_court_type_path(legal_aid_application)
      end

      it_behaves_like "a provider not authenticated"
    end
  end

  describe "GET /providers/:application_id/second_appeal_court_type" do
    subject(:get_second_appeal_court_type) { get providers_legal_aid_application_second_appeal_court_type_path(legal_aid_application) }

    before { get_second_appeal_court_type }

    it "returns http success" do
      expect(response).to have_http_status(:ok)
    end

    it "has expected path" do
      expect(page).to have_current_path(/.*\/second_appeal_court_type/, ignore_query: true)
    end

    it "displays the page" do
      expect(page)
        .to have_title("Which court will the second appeal be heard in?")
        .and have_css("h1", text: "Which court will the second appeal be heard in?")
    end
  end

  describe "PATCH /providers/:application_id/second_appeal_court_type" do
    subject(:post_second_appeal_court_type) { patch providers_legal_aid_application_second_appeal_court_type_path(legal_aid_application), params: }

    before do
      allow(LegalFramework::MeritsTasksService)
        .to receive(:call).with(legal_aid_application).and_return(smtl)
    end

    context "when form is saved using save and continue button" do
      let(:params) do
        {
          application_merits_task_appeal: { court_type: },
        }
      end

      context "when the user chooses a valid court type" do
        let(:court_type) { "court_of_appeal" }

        it "updates the appeal record with court_type" do
          expect { post_second_appeal_court_type }
            .to change { legal_aid_application.reload.appeal.court_type }
              .from(nil)
              .to("court_of_appeal")
        end

        it "redirects to the next page" do
          post_second_appeal_court_type
          expect(response).to redirect_to(next_flow_step)
        end
      end

      context "when the user chooses nothing" do
        let(:court_type) { nil }

        it "stays on the page if there is a validation error" do
          post_second_appeal_court_type

          expect(response).to have_http_status(:ok)

          within(".govuk-error-summary") do
            expect(page).to have_content("Select which court the appeal will be heard in")
          end
        end
      end

      context "when user changes answer" do
        before do
          legal_aid_application.appeal = create(:appeal, court_type: "court_of_appeal")
        end

        let(:court_type) { "supreme_court" }

        it "updates the appeal record" do
          expect { post_second_appeal_court_type }
            .to change { legal_aid_application.reload.appeal.court_type }
              .from("court_of_appeal")
              .to("supreme_court")
        end
      end
    end

    context "when the form is submitted with Save as draft button" do
      let(:params) do
        {
          application_merits_task_appeal: { court_type: },
          draft_button: "irrelevant",
        }
      end

      context "with a court_type chosen" do
        let(:court_type) { "court_of_appeal" }

        it "updates the appeal record with court_type value set" do
          expect { post_second_appeal_court_type }
            .to change { legal_aid_application.reload.appeal.court_type }
              .from(nil)
              .to("court_of_appeal")
        end

        it "redirects to the list of applications" do
          post_second_appeal_court_type
          expect(response).to redirect_to(submitted_providers_legal_aid_applications_path)
        end
      end

      context "with no answer chosen" do
        let(:court_type) { nil }

        it "creates the appeal record with no court_type set" do
          expect { post_second_appeal_court_type }
            .not_to change { legal_aid_application.reload.appeal.court_type }
              .from(nil)
        end

        it "redirects to the list of applications" do
          post_second_appeal_court_type
          expect(response).to redirect_to(submitted_providers_legal_aid_applications_path)
        end
      end
    end
  end
end
