require "rails_helper"

RSpec.describe Providers::Partners::StudentFinancesController do
  let(:legal_aid_application) { create(:legal_aid_application, partner:) }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/partners/student_finance" do
    subject(:request) do
      get providers_legal_aid_application_partners_student_finance_path(legal_aid_application)
    end

    let(:partner) { create(:partner, student_finance:, student_finance_amount: 1234.56) }
    let(:student_finance) { true }

    it "returns ok" do
      login_as provider
      request

      expect(response).to have_http_status(:ok)
    end

    context "when the application has student finance" do
      it "checks the 'Yes' radio button and displays the amount" do
        login_as provider
        request

        expect(page).to have_checked_field("Yes")
        expect(page).to have_field("partner[student_finance_amount]", with: "1,234.56")
      end
    end

    context "when the application does not have student finance" do
      let(:student_finance) { false }

      it "checks the 'No' radio button" do
        login_as provider
        request

        expect(page).to have_checked_field("No")
      end
    end

    context "when the provider is not authenticated" do
      before { request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is not authorised" do
      before do
        login_as create(:provider)
        request
      end

      it_behaves_like "an authenticated provider from a different firm"
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/partners/student_finance" do
    subject(:request) do
      patch providers_legal_aid_application_partners_student_finance_path(legal_aid_application),
            params: params.merge(button_clicked)
    end

    let(:partner) { create(:partner, student_finance:, student_finance_amount:) }
    let(:params) { { partner: { student_finance:, student_finance_amount: } } }
    let(:student_finance) { "false" }
    let(:student_finance_amount) { nil }
    let(:button_clicked) { {} }
    let(:continue_button) { { continue_button: "Save and continue" } }

    context "when the provider continues" do
      let(:button_clicked) { continue_button }

      context "when the provider selects `Yes`" do
        let(:student_finance) { "true" }
        let(:student_finance_amount) { "5000" }

        it "updates the partner" do
          login_as provider
          request

          expect(partner.reload.student_finance).to be true
          expect(partner.reload.student_finance_amount).to eq 5000
        end
      end

      context "when the provider selects `No`" do
        let(:student_finance) { "false" }

        it "updates the partner" do
          login_as provider
          request

          expect(partner.reload.student_finance).to be false
          expect(partner.reload.student_finance_amount).to be_nil
        end
      end

      context "when the provider selects `No` after previously selecting `Yes` and adding an amount" do
        before do
          partner.update!(student_finance: true, student_finance_amount: 1_000.22)
        end

        let(:student_finance) { "false" }
        let(:student_finance_amount) { 1_000.22 }

        it "updates the partner" do
          login_as provider

          expect { request }.to change { partner.reload.attributes.symbolize_keys }
            .from(hash_including(student_finance: true, student_finance_amount: 1_000.22))
            .to(hash_including(student_finance: false, student_finance_amount: nil))
        end
      end

      context "when the application is not using the bank upload journey" do
        it "redirects to the next page" do
          login_as provider
          request

          expect(response).to have_http_status(:redirect)
        end
      end
    end

    context "when the application has student finance" do
      let(:student_finance) { "true" }
      let(:student_finance_amount) { "1234.56" }

      it "updates the student finance amount" do
        partner
        login_as provider
        request

        expect(partner.reload.student_finance_amount).to eq(1234.56)
      end
    end

    context "when the form is invalid" do
      let(:student_finance) { "" }

      it "displays an error message" do
        login_as provider

        request

        expect(page).to have_error_message(
          "Select yes if your partner receives student finance",
        )
      end
    end

    context "when the provider is not authenticated" do
      before { request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is not authorised" do
      before do
        login_as create(:provider)
        request
      end

      it_behaves_like "an authenticated provider from a different firm"
    end

    context "when form submitted with Save as draft button" do
      let(:params) do
        {
          partner: { student_finance:, student_finance_amount: },
          draft_button: "Save and come back later",
        }
      end

      it "redirects to the list of applications" do
        login_as provider
        request
        expect(response).to redirect_to in_progress_providers_legal_aid_applications_path
      end
    end
  end
end
