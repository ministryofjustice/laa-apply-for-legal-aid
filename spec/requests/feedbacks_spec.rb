require "rails_helper"
require "sidekiq/testing"

RSpec.describe "FeedbacksController" do
  describe "POST /feedback" do
    Rack::Attack.enabled = false
    subject(:post_request) { post feedback_index_path, params:, headers: { "HTTP_REFERER" => originating_page } }

    let(:params) { { feedback: attributes_for(:feedback) } }
    let(:feedback) { Feedback.order(created_at: :asc).last }
    let(:feedback_params) { params[:feedback] }
    let(:provider) { create(:provider) }

    let(:session_vars) do
      {
        "page_history_id" => page_history_id,
      }
    end

    let(:address_lookup_page) { "http://localhost:3000/providers/applications/#{application.id}/address_lookup" }
    let(:additional_accounts_page) { "http://localhost:3000/citizens/additional_accounts" }
    let(:originating_page) { "page_outside_apply_service" }
    let(:application) { create(:application, provider:) }
    let(:page_history_id) { SecureRandom.uuid }
    let(:page_history) { [address_lookup_page, "/feedback"] }

    before do
      page_history_stub = instance_double(PageHistoryService, read: page_history.to_json, write: nil)
      allow(PageHistoryService).to receive(:new).with(page_history_id:).and_return(page_history_stub)

      set_session(session_vars)
    end

    context "with valid data" do
      context "with any type of user" do
        it "create a feedback" do
          expect { post_request }.to change(Feedback, :count).by(1)
        end

        it "redirects to thanks action" do
          post_request
          expect(response).to redirect_to feedback_thanks_path

          follow_redirect!
          expect(page).to have_content("Thank you for your feedback")
        end

        it "gathers browser data" do
          post_request
          expect(feedback.browser).not_to be_empty
          expect(feedback.os).not_to be_empty
        end

        it "applies params to new feedback" do
          post_request
          expect(feedback.done_all_needed).to eq(feedback_params[:done_all_needed])
          expect(feedback.satisfaction).to eq(feedback_params[:satisfaction])
          expect(feedback.difficulty).to eq(feedback_params[:difficulty])
          expect(feedback.improvement_suggestion).to eq(feedback_params[:improvement_suggestion])
        end
      end

      context "when coming from a provider path while signed in" do
        let(:originating_page) { address_lookup_page }

        before { sign_in provider }

        it "adds provider-specific data to feedback record" do
          post_request
          expect(feedback.source).to eq "Provider"
          expect(feedback.email).to eq provider.email
          expect(feedback.originating_page).to eq URI(address_lookup_page).path.split("/").last
        end

        context "when feedback given during application" do
          let(:page_history) do
            [originating_page, "/feedback/new"]
          end

          it "adds provider-specific data to feedback record" do
            post_request
            expect(feedback.source).to eq "Provider"
            expect(feedback.email).to eq provider.email
            expect(feedback.originating_page).to eq URI(address_lookup_page).path.split("/").last
          end
        end

        context "when feedback given outside of an application" do
          let(:page_history) do
            ["/feedback/new"]
          end

          it "adds provider-specific data to feedback record" do
            post_request
            expect(feedback.source).to eq "Provider"
            expect(feedback.email).to eq provider.email
            expect(feedback.originating_page).to eq URI(address_lookup_page).path.split("/").last
          end
        end
      end

      context "when coming from a provider path after logging out" do
        let(:originating_page) { address_lookup_page }
        let(:params) { { feedback: attributes_for(:feedback), signed_out: true } }

        it "adds signed-out provider specific attributes" do
          post_request
          expect(feedback.source).to eq "Provider"
          expect(feedback.email).to eq provider.email
          expect(feedback.originating_page).to eq "/providers/sign_out?locale=en"
        end
      end

      context "when coming from a citizen/applicant path" do
        let(:originating_page) { additional_accounts_page }

        let(:session_vars) do
          {
            "current_application_id" => application.id,
          }
        end

        it "adds applicant specific data" do
          post_request
          expect(feedback.source).to eq "Applicant"
          expect(feedback.email).to eq provider.email
          expect(feedback.originating_page).to eq URI(additional_accounts_page).path.split("/").last
        end
      end

      context "when coming from a non citizen or provider path" do
        let(:originating_page) { "whatever" }

        it "records unknown source" do
          post_request
          expect(feedback.source).to eq("Unknown")
          expect(feedback.originating_page).to eq "whatever"
        end
      end
    end

    context "with no done_all_needed params" do
      let(:params) { { feedback: { done_all_needed: "" } } }

      it "does not create a feedback to record browser data" do
        expect { post_request }.not_to change(Feedback, :count)
      end

      it "shows errors on the page" do
        post_request
        expect(page).to have_content("Select yes if you were you able to do what you needed today")
      end
    end

    context "with no satisfaction params" do
      let(:params) { { feedback: { satisfaction: "" } } }

      it "does not create a feedback record" do
        expect { post_request }.not_to change(Feedback, :count)
      end

      it "shows errors on the page" do
        post_request
        expect(page).to have_content("Select how satisfied you were with the service")
      end
    end

    context "with no difficulty params" do
      let(:params) { { feedback: { difficulty: "" } } }

      it "does not create a feedback record" do
        expect { post_request }.not_to change(Feedback, :count)
      end

      it "shows errors on the page" do
        post_request
        expect(page).to have_content("Select how easy or difficult it was to apply for legal aid using the new service")
      end
    end

    context "with all mandatory params only" do
      let(:params) do
        {
          feedback:
            {
              done_all_needed: "false",
              difficulty: "neither_difficult_nor_easy",
              satisfaction: "neither_dissatisfied_nor_satisfied",
            },
        }
      end

      it "creates a feedback to record" do
        expect { post_request }.to change(Feedback, :count).by(1)
      end

      it "shows success" do
        post_request
        follow_redirect!
        expect(page).to have_content("Thank you for your feedback")
      end
    end

    # NOTE: exercises edge case where feedback page was accessed directly, not via a link on the service,
    # and is submitted with or without errors.
    context "when there is no originating page - i.e. session[feedback_return_path] is nil" do
      let(:originating_page) { nil }

      it "can still be submitted successfully" do
        post_request
        expect(response).to redirect_to feedback_thanks_path
      end
    end

    context "when submitting feedback using link in submission email" do
      let(:application) { create(:legal_aid_application) }
      let(:params) { { feedback: attributes_for(:feedback), application_id: application.id, submission_feedback: "true" } }

      it "adds signed-out submission_feedback specific attributes" do
        post_request
        expect(feedback.legal_aid_application_id).to eq application.id
        expect(feedback.originating_page).to eq "submission_feedback"
      end
    end

    context "with Rack::Attack enabled" do
      around do |test|
        Rack::Attack.reset!
        Rack::Attack.enabled = true
        test.run
        Rack::Attack.enabled = false
      end

      describe "when three feedbacks are submitted in quick succession" do
        it "returns a 429 status for the final submission" do
          freeze_time

          post feedback_index_path, params:, headers: { "HTTP_REFERER" => originating_page }
          expect(response).to have_http_status(:redirect)
          expect(Feedback.count).to eq 1

          post feedback_index_path, params:, headers: { "HTTP_REFERER" => originating_page }
          expect(response).to have_http_status(:redirect)
          expect(Feedback.count).to eq 2

          post feedback_index_path, params:, headers: { "HTTP_REFERER" => originating_page }
          expect(response).to have_http_status(:too_many_requests)
          expect(Feedback.count).to eq 2
        end
      end

      describe "when feedback is submitted with crawlergo" do
        let(:params) { { feedback: attributes_for(:feedback, improvement_suggestion: "Crawlergo is orsum") } }

        it "returns a 403 status" do
          post_request
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end

  describe "GET /feedback/new" do
    let(:session_vars) { {} }

    before do
      set_session(session_vars)
      get new_feedback_path
    end

    it "renders the page" do
      expect(response).to have_http_status(:ok)
    end

    it "displays the expected questions" do
      expect(page)
        .to have_content("1. Were you able to do what you needed today?")
        .and have_content("2. How easy or difficult was it to use this service?")
        .and have_content("3. What do you think about the amount of time it took you to use this service?")
        .and have_content("4. Overall, how satisfied were you with this service?")
        .and have_content("5. Do you have any feedback or suggestions on how we could improve the service?")
        .and have_content("6. If you're happy to be contacted for research opportunities with the Legal Aid Agency (LAA), please provide your contact details")
    end

    it "has a hidden form field to show whether the feedback originates from a submission email with false value" do
      expect(response.body).to include('<input type="hidden" name="submission_feedback" id="submission_feedback" value="false" autocomplete="off" />')
    end

    context "when here as applicant or signed in provider" do
      let(:session_vars) { {} }

      it "hash a hidden form field with no value" do
        expect(response.body).to include('<input type="hidden" name="signed_out" id="signed_out" autocomplete="off" />')
      end
    end

    context "with provider signed out" do
      let(:provider) { create(:provider) }

      before do
        sign_in provider
        delete destroy_provider_session_path
        get new_feedback_path
      end

      it "does not display a back button" do
        expect(unescaped_response_body).not_to match(I18n.t(".generic.back"))
      end
    end
  end

  describe "GET /submission_feedback/:application_ref" do
    let(:session_vars) { {} }
    let(:application) { create(:legal_aid_application) }

    before do
      get "/submission_feedback/#{application.application_ref}"
    end

    it "renders the page" do
      expect(response).to have_http_status(:ok)
    end

    it "displays the provider difficulty question" do
      expect(page)
        .to have_content("1. Were you able to do what you needed today?")
        .and have_content("2. How easy or difficult was it to use this service?")
        .and have_content("3. What do you think about the amount of time it took you to use this service?")
        .and have_content("4. Overall, how satisfied were you with this service?")
        .and have_content("5. Do you have any feedback or suggestions on how we could improve the service?")
        .and have_content("6. If you're happy to be contacted for research opportunities with the Legal Aid Agency (LAA), please provide your contact details")
    end

    it "has a hidden form field to show whether the feedback originates from a submission email with true value" do
      expect(response.body).to include('<input type="hidden" name="submission_feedback" id="submission_feedback" value="true" autocomplete="off" />')
    end

    it "has a hidden form field to store the application id" do
      expect(response.body).to include("<input type=\"hidden\" name=\"application_id\" id=\"application_id\" value=\"#{application.id}\" autocomplete=\"off\" />")
    end

    context "when here as applicant or signed in provider" do
      let(:session_vars) { {} }

      it "hash a hidden form field with no value" do
        expect(response.body).to include('<input type="hidden" name="signed_out" id="signed_out" autocomplete="off" />')
      end
    end
  end

  describe "GET /feedback/thanks" do
    let(:feedback) { create(:feedback) }
    let(:provider) { create(:provider) }

    before do
      sign_in provider
      get feedback_thanks_path(feedback)
    end

    it "renders the page" do
      expect(response).to have_http_status(:ok)
    end

    it "displays a message" do
      expect(unescaped_response_body).to match("Thank you for your feedback")
    end
  end
end
