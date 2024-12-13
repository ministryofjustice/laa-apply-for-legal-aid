require "rails_helper"

RSpec.describe Providers::ApplicationMeritsTask::SecondAppealsController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_public_law_family_appeal) }
  let(:provider) { legal_aid_application.provider }
  let(:smtl) { create(:legal_framework_merits_task_list, :pbm01a_as_applicant, legal_aid_application:) }

  before { login_as provider }

  context "when not authenticated" do
    before { logout }

    context "when GET /providers/:application_id/second_appeal" do
      before do
        get providers_legal_aid_application_second_appeal_path(legal_aid_application)
      end

      it_behaves_like "a provider not authenticated"
    end

    context "when PATCH /providers/:application_id/second_appeal" do
      before do
        patch providers_legal_aid_application_second_appeal_path(legal_aid_application)
      end

      it_behaves_like "a provider not authenticated"
    end
  end

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

    context "when form is saved using save and continue button" do
      let(:params) do
        {
          application_merits_task_appeal: { second_appeal: },
        }
      end

      context "when the user chooses yes" do
        let(:second_appeal) { "true" }

        it "creates the appeal record with second_appeal true" do
          expect { post_second_appeal }
            .to change { legal_aid_application.reload.appeal }
              .from(nil)
              .to(kind_of(ApplicationMeritsTask::Appeal))

          expect(legal_aid_application.reload.appeal.second_appeal).to be true
        end

        it "redirects to the next page", skip: "TODO: AP-5530" do
          post_second_appeal
          expect(response).to redirect_to(:second_appeal_court)
        end
      end

      context "when the user chooses no" do
        let(:second_appeal) { "false" }

        it "creates the appeal record with second_appeal false" do
          expect { post_second_appeal }
            .to change { legal_aid_application.reload.appeal }
              .from(nil)
              .to(kind_of(ApplicationMeritsTask::Appeal))

          expect(legal_aid_application.reload.appeal.second_appeal).to be false
        end

        it "redirects to the next page", skip: "TODO: AP-5530" do
          post_second_appeal
          expect(response).to redirect_to(:original_judge_level)
        end
      end

      context "when the user chooses nothing" do
        let(:second_appeal) { nil }

        it "stays on the page if there is a validation error" do
          post_second_appeal

          expect(response).to have_http_status(:ok)

          within(".govuk-error-summary") do
            expect(page).to have_content("Select yes if this is a second appeal")
          end
        end
      end

      context "when user changes answer" do
        before do
          legal_aid_application.appeal = create(:appeal, second_appeal: false)
        end

        let(:second_appeal) { true }

        it "updates the appeal record" do
          expect { post_second_appeal }
            .to change { legal_aid_application.reload.appeal.second_appeal }
              .from(false)
              .to(true)
        end
      end
    end

    context "when the form is submitted with Save as draft button" do
      let(:params) do
        {
          application_merits_task_appeal: { second_appeal: },
          draft_button: "irrelevant",
        }
      end

      context "with a yes or no chosen" do
        let(:second_appeal) { "true" }

        it "creates the appeal record with second_appeal value set" do
          expect { post_second_appeal }
            .to change { legal_aid_application.reload.appeal }
              .from(nil)
              .to(kind_of(ApplicationMeritsTask::Appeal))

          expect(legal_aid_application.reload.appeal.second_appeal).to be true
        end

        it "redirects to the list of applications" do
          post_second_appeal
          expect(response).to redirect_to(submitted_providers_legal_aid_applications_path)
        end
      end

      context "with no answer chosen" do
        let(:second_appeal) { nil }

        it "creates the appeal record with no second_appeal set" do
          expect { post_second_appeal }
            .to change { legal_aid_application.reload.appeal }
              .from(nil)
              .to(kind_of(ApplicationMeritsTask::Appeal))

          expect(legal_aid_application.reload.appeal.second_appeal).to be_nil
        end

        it "redirects to the list of applications" do
          post_second_appeal
          expect(response).to redirect_to(submitted_providers_legal_aid_applications_path)
        end
      end
    end
  end
end
