require "rails_helper"

RSpec.describe "student_finance", type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :with_non_passported_state_machine }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/means/student_finance" do
    subject(:request) { get providers_legal_aid_application_means_student_finance_path(legal_aid_application) }

    before { login_as provider }

    it "returns success" do
      request
      expect(response).to be_successful
    end

    it "contains the correct content" do
      request
      expect(response.body).to include("Does your client receive student finance?")
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/means/student_finance" do
    subject(:request) { patch providers_legal_aid_application_means_student_finance_path(legal_aid_application), params: }

    before { login_as provider }

    let(:params) do
      {
        irregular_income: {
          amount:,
          student_finance:,
        },
      }
    end

    context "when irregular incomes do not already exist" do
      let(:amount) { 2345 }
      let(:student_finance) { "true" }

      it "redirects to the identify_types_of_outgoing page" do
        request
        expect(response).to redirect_to(providers_legal_aid_application_identify_types_of_outgoing_path)
      end

      it "creates an irregular income record" do
        expect { request }.to change(IrregularIncome, :count).by(1)
      end

      it "creates an irregular income record with the expected attributes" do
        request
        irregular_income = legal_aid_application.reload.irregular_incomes.first
        expect(irregular_income).to have_attributes(amount: 2345,
                                                    frequency: "annual",
                                                    income_type: "student_loan")
      end
    end

    context "when irregular incomes already exist" do
      let(:amount) { 5000 }
      let(:student_finance) { "true" }

      before do
        patch(providers_legal_aid_application_means_student_finance_path(legal_aid_application),
              params: { irregular_income: { amount: 1111, student_finance: "true" } })
      end

      it "does not create a record" do
        expect { request }.not_to change(IrregularIncome, :count)
      end

      it "updates the existing record with the expected attributes" do
        request
        irregular_income = legal_aid_application.reload.irregular_incomes.first
        expect(irregular_income.amount).to eq 5000
      end
    end

    context "when amount field is empty" do
      let(:amount) { "" }
      let(:student_finance) { "true" }

      it "displays an error" do
        request
        expect(response.body).to include I18n.t("activemodel.errors.models.irregular_income.attributes.amount.blank")
      end
    end

    context "when responds NO to student finance" do
      let(:student_finance) { "false" }
      let(:amount) { "" }

      it "redirects to the identify_types_of_outgoing page" do
        request
        expect(response).to redirect_to(providers_legal_aid_application_identify_types_of_outgoing_path)
      end

      it "updates the legal aid application record" do
        expect { request }.to change { legal_aid_application.reload.student_finance }.from(nil).to(false)
      end
    end

    context "when student finance is nil" do
      let(:student_finance) { nil }
      let(:amount) { "" }

      it "displays an error" do
        request
        expect(response.body).to include I18n.t("activemodel.errors.models.legal_aid_application.attributes.student_finance.blank")
      end
    end
  end
end
