require "rails_helper"

RSpec.describe Providers::Partners::UnexpectedEmploymentIncomesController do
  let(:application) { create(:legal_aid_application, :with_non_passported_state_machine, :with_transaction_period, partner:) }
  let(:partner) { create(:partner, :not_employed) }
  let(:employment) { create(:employment, legal_aid_application: application, owner_id: partner.id, owner_type: partner.class) }
  let(:provider) { application.provider }
  let(:setup_tasks) { {} }
  let(:individual_with_determiner) { "the partner" }

  describe "GET /providers/applications/:id/partners/unexpected_employed_income" do
    subject(:get_employment_income) { get providers_legal_aid_application_partners_unexpected_employment_income_path(application) }

    context "when the provider is not authenticated" do
      before do
        get_employment_income
      end

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        setup_tasks
        login_as provider
        get_employment_income
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      context "when partner is not employed but has employment payment records" do
        let(:setup_tasks) do
          create(:employment, :with_payments_in_transaction_period, legal_aid_application: application, owner_id: partner.id, owner_type: partner.class)
        end

        it "displays correct text when partner is not_employed" do
          expect(unescaped_response_body).to include(I18n.t("shared.unexpected_employment_incomes.page_title", individual_with_determiner:))
          expect(unescaped_response_body).to include(I18n.t("shared.unexpected_employment_incomes.hmrc_not_employed", individual_with_determiner:))
        end
      end
    end
  end

  describe "PATCH /providers/applications/:id/partners/unexpected_employed_income" do
    subject(:request) { patch providers_legal_aid_application_partners_unexpected_employment_income_path(application), params: params.merge(submit_button) }

    let(:params) do
      {
        partner: {
          extra_employment_information_details:,
        },
      }
    end
    let(:extra_employment_information_details) { Faker::Lorem.paragraph }

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "when Form submitted with continue button" do
        let(:submit_button) do
          {
            continue_button: "Continue",
          }
        end

        it "updates partner extra employment details" do
          request
          expect(partner.reload.extra_employment_information_details).not_to be_empty
        end

        it "redirects to the next step" do
          request
          expect(response).to have_http_status(:redirect)
        end

        context "with invalid params" do
          let(:extra_employment_information_details) { "" }

          it "displays error" do
            request
            expect(unescaped_response_body).to include(I18n.t("activemodel.errors.models.partner.attributes.extra_employment_information_details.blank"))
          end
        end
      end

      context "when Form submitted with Save as draft button" do
        let(:submit_button) do
          {
            draft_button: "Save as draft",
          }
        end

        context "and after success" do
          before do
            login_as provider
            request
            application.reload
          end

          it "updates the legal_aid_application.extra_employment_information" do
            expect(partner.reload.extra_employment_information_details).not_to be_empty
          end

          it "redirects to the list of applications" do
            expect(response).to redirect_to providers_legal_aid_applications_path
          end
        end
      end
    end
  end
end
