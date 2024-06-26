require "rails_helper"

RSpec.describe "citizen additional accounts request test" do
  let(:application) { create(:application, :with_applicant, :with_non_passported_state_machine, :applicant_entering_means) }

  before { sign_in_citizen_for_application(application) }

  describe "GET /citizens/additional_accounts" do
    before { get citizens_additional_accounts_path }

    it "returns http success" do
      expect(response).to have_http_status(:ok)
    end
  end

  context "when application is in use_ccms state" do
    it "has reset the state and ccms_reason" do
      application.use_ccms!(:no_online_banking)
      get citizens_additional_accounts_path
      expect(application.reload.state).to eq "applicant_entering_means"
      expect(application.ccms_reason).to be_nil
    end
  end

  describe "GET /citizens/additional_accounts/new when they are on the CCMS path" do
    before { application.use_ccms!(:no_online_banking) }

    it "has reset the state and ccms_reason" do
      get new_citizens_additional_account_path(application)
      expect(application.reload.state).to eq "applicant_entering_means"
      expect(application.ccms_reason).to be_nil
    end
  end

  context "when an applicant revisits the page to change their answer" do
    before do
      application.update!(has_offline_accounts: true)
      application.use_ccms!(:offline_accounts)
    end

    it "checks that offline account is reset to nil" do
      get citizens_additional_accounts_path
      expect(application.reload.has_offline_accounts).to be_nil
      expect(application.state).to eq "applicant_entering_means"
    end
  end

  describe "POST /citizens/additional_accounts" do
    let(:params) { {} }

    before { post citizens_additional_accounts_path, params: }

    it "does not redirect if no choice submitted" do
      expect(response).to have_http_status(:ok)
    end

    it "displays an error" do
      expect(response.body).to match("govuk-error-summary")
      expect(response.body).to include("Select yes if you have accounts with other banks")
    end

    context "with Yes submitted" do
      let(:params) { { binary_choice_form: { additional_account: "true" } } }

      it "redirects to new action" do
        expect(response).to redirect_to(new_citizens_additional_account_path)
      end
    end

    context "with No submitted" do
      let(:params) { { binary_choice_form: { additional_account: "false" } } }

      it "redirects to /citizens/identify_types_of_income(.:format)" do
        expect(response).to redirect_to(citizens_check_answers_path)
      end
    end
  end

  describe "GET /citizens/additional_accounts/new" do
    before { get new_citizens_additional_account_path }

    it "returns http success" do
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH/PUT /citizens/additional_accounts" do
    let(:params) { {} }

    before { patch citizens_additional_account_path(id: :update), params: }

    it "does not redirect if no choice submitted" do
      expect(response).to have_http_status(:ok)
    end

    it "displays an error" do
      expect(response.body).to match("govuk-error-summary")
      expect(response.body).to include("Select yes if you have current accounts you cannot access online")
    end

    context "with Yes submitted" do
      let(:params) { { binary_choice_form: { has_offline_accounts: "false" } } }

      it "redirects to select another bank" do
        expect(response).to redirect_to(citizens_banks_path)
      end

      it "does not record choice on legal_aid_application" do
        expect(application.reload).not_to have_offline_accounts
      end
    end

    context "with No submitted" do
      let(:params) { { binary_choice_form: { has_offline_accounts: "true" } } }

      it "redirects to contact provider path" do
        expect(response).to redirect_to(citizens_contact_provider_path)
      end

      it "records choice on legal_aid_application" do
        expect(application.reload).to have_offline_accounts
      end
    end
  end
end
