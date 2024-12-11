require "rails_helper"

RSpec.describe Providers::ApplicationMeritsTask::OriginalJudgeLevelsController do
  let(:legal_aid_application) do
    create(:legal_aid_application,
           :with_public_law_family_appeal,
           appeal: create(:appeal,
                          second_appeal: false,
                          original_judge_level: nil))
  end

  let(:provider) { legal_aid_application.provider }
  let(:smtl) { create(:legal_framework_merits_task_list, :pbm01a_as_applicant, legal_aid_application:) }

  before { login_as provider }

  context "when not authenticated" do
    before { logout }

    context "when GET /providers/:application_id/original_case_judge_level" do
      before do
        get providers_legal_aid_application_original_judge_level_path(legal_aid_application)
      end

      it_behaves_like "a provider not authenticated"
    end

    context "when PATCH /providers/:application_id/original_case_judge_level" do
      before do
        patch providers_legal_aid_application_original_judge_level_path(legal_aid_application)
      end

      it_behaves_like "a provider not authenticated"
    end
  end

  describe "GET /providers/:application_id/original_case_judge_level" do
    subject(:get_original_judge_level) { get providers_legal_aid_application_original_judge_level_path(legal_aid_application) }

    before { get_original_judge_level }

    it "returns http success" do
      expect(response).to have_http_status(:ok)
    end

    it "has expected path" do
      expect(page).to have_current_path(/.*\/original_case_judge_level/, ignore_query: true)
    end

    it "displays the page" do
      expect(page)
        .to have_title("What level of judge heard the original case?")
        .and have_css("h1", text: "What level of judge heard the original case?")
    end
  end

  describe "PATCH /providers/:application_id/original_case_judge_level" do
    subject(:post_original_judge_level) { patch providers_legal_aid_application_original_judge_level_path(legal_aid_application), params: }

    before do
      allow(LegalFramework::MeritsTasksService)
        .to receive(:call).with(legal_aid_application).and_return(smtl)
    end

    context "when form is saved using save and continue button" do
      let(:params) do
        {
          application_merits_task_appeal: { original_judge_level: },
        }
      end

      context "when the user chooses a valid judge level" do
        let(:original_judge_level) { "district_judge" }

        it "updates the appeal record with original_judge_level" do
          expect { post_original_judge_level }
            .to change { legal_aid_application.reload.appeal.original_judge_level }
              .from(nil)
              .to("district_judge")
        end

        it "redirects to the next page", skip: "TODO: AP-5531/5532" do
          post_original_judge_level
          expect(response).to redirect_to(:appeal_court_type)
        end
      end

      context "when the user chooses nothing" do
        let(:original_judge_level) { nil }

        it "stays on the page if there is a validation error" do
          post_original_judge_level

          expect(response).to have_http_status(:ok)

          within(".govuk-error-summary") do
            expect(page).to have_content("Select what level of judge heard the original case")
          end
        end
      end

      context "when user changes answer" do
        before do
          legal_aid_application.appeal = create(:appeal, original_judge_level: "district_judge")
        end

        let(:original_judge_level) { "family_panel_magistrates" }

        it "updates the appeal record" do
          expect { post_original_judge_level }
            .to change { legal_aid_application.reload.appeal.original_judge_level }
              .from("district_judge")
              .to("family_panel_magistrates")
        end
      end
    end

    context "when the form is submitted with Save as draft button" do
      let(:params) do
        {
          application_merits_task_appeal: { original_judge_level: },
          draft_button: "irrelevant",
        }
      end

      context "with a judge level chosen" do
        let(:original_judge_level) { "district_judge" }

        it "updates the appeal record with original_judge_level value set" do
          expect { post_original_judge_level }
            .to change { legal_aid_application.reload.appeal.original_judge_level }
              .from(nil)
              .to("district_judge")
        end

        it "redirects to the list of applications" do
          post_original_judge_level
          expect(response).to redirect_to(submitted_providers_legal_aid_applications_path)
        end
      end

      context "with no answer chosen" do
        let(:original_judge_level) { nil }

        it "creates the appeal record with no original_judge_level set" do
          expect { post_original_judge_level }
            .not_to change { legal_aid_application.reload.appeal.original_judge_level }
              .from(nil)
        end

        it "redirects to the list of applications" do
          post_original_judge_level
          expect(response).to redirect_to(submitted_providers_legal_aid_applications_path)
        end
      end
    end
  end
end
