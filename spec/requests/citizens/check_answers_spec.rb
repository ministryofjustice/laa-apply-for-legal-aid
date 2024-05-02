require "rails_helper"

RSpec.describe "check your answers requests" do
  include ActionView::Helpers::NumberHelper
  let(:firm) { create(:firm) }
  let(:has_restrictions) { true }
  let(:restrictions_details) { Faker::Lorem.paragraph }
  let(:provider) { create(:provider, firm:) }
  let(:credit) { create(:transaction_type, :credit_with_standard_name) }
  let(:debit) { create(:transaction_type, :debit_with_standard_name) }
  let!(:legal_aid_application) do
    create(:legal_aid_application,
           :with_non_passported_state_machine,
           :applicant_entering_means,
           :with_everything,
           provider:)
  end

  before do
    create(:legal_aid_application_transaction_type, legal_aid_application:, transaction_type: credit)
    create(:legal_aid_application_transaction_type, legal_aid_application:, transaction_type: debit)
    sign_in_citizen_for_application(legal_aid_application)
  end

  describe "GET /citizens/check_answers" do
    subject(:get_request) { get "/citizens/check_answers" }

    before { get_request }

    it "returns http success" do
      expect(response).to have_http_status(:ok)
    end

    it "displays the correct section headings" do
      expect(response.body).to include("Your bank accounts")
    end

    it 'changes the state to "checking_citizen_answers"' do
      expect(legal_aid_application.reload).to be_checking_citizen_answers
    end

    it "displays the name of the firm" do
      get_request
      expect(unescaped_response_body).to include(firm.name)
    end

    context "with firms with special characters in the name" do
      let(:firm) { create(:firm, name: %q(O'Keefe & Sons - "Pay less with the master builders!")) }

      it "finds the firm even though it has special characters" do
        get_request
        expect(unescaped_response_body).to include(firm.name)
      end
    end
  end

  describe "PATCH /citizens/check_answers/continue" do
    subject(:patch_request) { patch "/citizens/check_answers/continue" }

    before do
      legal_aid_application.check_citizen_answers!
    end

    it "redirects to next step" do
      patch_request
      expect(response).to redirect_to(flow_forward_path)
    end

    it "changes the state" do
      expect { patch_request }.to change { legal_aid_application.reload.state }
    end

    it "sets the application state to analysing_bank_transactions" do
      patch_request
      expect(legal_aid_application.reload.state).to eq "analysing_bank_transactions"
      expect(legal_aid_application.completed_at).to be_within(1).of(Time.current)
    end

    it "changes the provider step to start_chances_of_success" do
      patch_request
      expect(legal_aid_application.reload.provider_step).to eq("client_completed_means")
    end

    it "records when the declaration was accepted" do
      patch_request
      expect(legal_aid_application.reload.declaration_accepted_at).to be_between(2.seconds.ago, Time.current)
    end

    it "syncs the application" do
      expect(CleanupCapitalAttributes).to receive(:call).with(legal_aid_application)
      patch_request
    end
  end
end
