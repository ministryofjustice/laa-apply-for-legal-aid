require "rails_helper"

RSpec.describe Providers::Partners::EmploymentIncomesController do
  let(:application) { create(:legal_aid_application, :with_non_passported_state_machine, :with_transaction_period, partner:) }
  let(:partner) { create(:partner, :employed) }
  let(:employment) { create(:employment, legal_aid_application: application, owner_id: partner.id, owner_type: partner.class) }
  let(:provider) { application.provider }
  let(:setup_tasks) { {} }

  describe "GET /providers/applications/:id/partners/employment_income" do
    subject(:get_employment_income) { get providers_legal_aid_application_partners_employment_income_path(application) }

    context "when the provider is not authenticated" do
      before { get_employment_income }

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

      context "when partner is employed" do
        let(:partner) { create(:partner, :employed) }

        it "displays correct text" do
          expect(unescaped_response_body).to include(I18n.t("shared.employment_income.page_title", name: partner.full_name))
          expect(unescaped_response_body).not_to match(/You told us .* is not employed/)
        end
      end
    end
  end

  describe "PATCH /providers/applications/:id/partners/employment_income" do
    subject(:request) { patch providers_legal_aid_application_partners_employment_income_path(application), params: params.merge(submit_button) }

    let(:params) do
      {
        partner: {
          extra_employment_information:,
          extra_employment_information_details:,
        },
      }
    end
    let(:extra_employment_information_details) { Faker::Lorem.paragraph }
    let(:extra_employment_information) { "true" }

    context "when the provider is authenticated" do
      before do
        login_as provider
        request
      end

      context "when Form submitted with continue button" do
        let(:submit_button) do
          {
            continue_button: "Continue",
          }
        end

        it "sets the partner extra employment information attribute to true" do
          expect(partner.reload.extra_employment_information).to be true
        end

        it "updates the partner extra employment information details" do
          expect(partner.reload.extra_employment_information_details).not_to be_empty
        end

        it "redirects to the next step" do
          expect(response).to have_http_status(:redirect)
        end

        context "with invalid params" do
          let(:extra_employment_information_details) { "" }

          it "displays error" do
            expect(unescaped_response_body).to include(I18n.t("activemodel.errors.models.partner.attributes.extra_employment_information_details.blank"))
          end

          context "with no params" do
            let(:extra_employment_information) { "" }

            it "displays error" do
              expect(unescaped_response_body).to include(I18n.t("activemodel.errors.models.partner.attributes.extra_employment_information.blank"))
            end
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
            application.reload
          end

          it "sets the partner extra employment information attribute to true" do
            expect(partner.reload.extra_employment_information).to be true
          end

          it "updates the partner extra employment information details" do
            expect(partner.reload.extra_employment_information_details).not_to be_empty
          end

          it "redirects to the list of applications" do
            expect(response).to redirect_to submitted_providers_legal_aid_applications_path
          end
        end
      end
    end
  end
end
