require "rails_helper"

RSpec.describe "employed incomes request" do
  let(:application) { create(:legal_aid_application, :with_non_passported_state_machine, :with_transaction_period, applicant:) }
  let(:applicant) { create(:applicant, :not_employed) }
  let(:employment) { create(:employment, legal_aid_application: application, owner_id: applicant.id, owner_type: applicant.class) }
  let(:provider) { application.provider }
  let(:setup_tasks) { {} }

  describe "GET /providers/applications/:id/means/unexpected_employed_income" do
    subject(:get_employment_income) { get providers_legal_aid_application_means_unexpected_employment_income_path(application) }

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

      context "when applicant is not employed but has employment payment records" do
        let(:setup_tasks) do
          create(:employment, :with_payments_in_transaction_period, legal_aid_application: application, owner_id: applicant.id, owner_type: applicant.class)
        end

        it "displays correct text when applicant is not_employed" do
          expect(unescaped_response_body).to include(I18n.t("providers.means.unexpected_employment_incomes.show.page_title"))
          expect(unescaped_response_body).to include(I18n.t("providers.means.unexpected_employment_incomes.show.hmrc_not_employed"))
        end
      end
    end
  end

  describe "PATCH /providers/applications/:id/means/unexpected_employed_income" do
    subject(:request) { patch providers_legal_aid_application_means_unexpected_employment_income_path(application), params: params.merge(submit_button) }

    let(:params) do
      {
        legal_aid_application: {
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

        it "updates legal aid application restriction information" do
          request
          expect(application.reload.extra_employment_information_details).not_to be_empty
        end

        context "when the application is using the bank upload journey" do
          let(:application) { create(:legal_aid_application, provider_received_citizen_consent: false) }

          it "redirects to the regular income page" do
            request
            expect(response).to redirect_to(providers_legal_aid_application_means_regular_incomes_path(application))
          end
        end

        context "when the application is not using the bank upload journey" do
          it "redirects to the identify types of income page" do
            request
            expect(response).to redirect_to(providers_legal_aid_application_means_identify_types_of_income_path(application))
          end
        end

        context "with invalid params" do
          let(:extra_employment_information_details) { "" }

          it "displays error" do
            request
            expect(unescaped_response_body).to include(I18n.t("activemodel.errors.models.legal_aid_application.attributes.extra_employment_information_details.blank"))
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
            expect(application.extra_employment_information_details).not_to be_empty
          end

          it "redirects to the list of applications" do
            expect(response).to redirect_to providers_legal_aid_applications_path
          end
        end
      end
    end
  end
end
