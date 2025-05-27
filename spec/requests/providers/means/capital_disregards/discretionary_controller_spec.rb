require "rails_helper"

RSpec.describe Providers::Means::CapitalDisregards::DiscretionaryController do
  let(:application) { create(:legal_aid_application, :with_applicant) }
  let(:provider) { application.provider }

  describe "GET providers/applications/:id/means/capital_disregards/payments_to_review" do
    subject(:get_request) { get providers_legal_aid_application_means_capital_disregards_discretionary_path(application) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_request
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays the show page" do
        expect(response.body).to include("Payments to be reviewed")
      end
    end
  end

  describe "PATCH providers/applications/:id/means/capital_disregards/payments_to_review" do
    let(:none_selected) { "" }
    let(:discretionary_capital_disregards) { %w[backdated_benefits national_emergencies_trust] }
    let(:params) do
      {
        providers_means_capital_disregards_discretionary_form: {
          discretionary_capital_disregards:,
          none_selected:,
        },
      }
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "when submitted with Continue button" do
        let(:submit_button) do
          { continue_button: "Continue" }
        end

        before do
          patch providers_legal_aid_application_means_capital_disregards_discretionary_path(application), params: params.merge(submit_button)
        end

        context "with valid params" do
          it "redirects to the next page" do
            expect(response).to have_http_status(:redirect)
          end

          it "updates the record" do
            expect(application.discretionary_capital_disregards.count).to eq 2
            expect(application.discretionary_capital_disregards.pluck(:mandatory)).to contain_exactly(false, false)
            expect(application.discretionary_capital_disregards.pluck(:name)).to match_array(%w[backdated_benefits national_emergencies_trust])
          end
        end

        context "with nothing" do
          let(:none_selected) { "true" }
          let(:discretionary_capital_disregards) { [] }

          context "with 'none of these' checkbox selected" do
            it "redirects to the next page" do
              expect(response).to have_http_status(:redirect)
            end

            it "does not create a capital_discretionary_disregard record" do
              expect(application.discretionary_capital_disregards.count).to eq 0
            end
          end

          context "with 'none of these' checkbox not selected" do
            let(:none_selected) { "" }

            it "the response includes the error message" do
              expect(response.body).to include(I18n.t("activemodel.errors.models.discretionary_capital_disregards.attributes.base.none_selected"))
            end
          end
        end
      end

      context "with form submitted using Save as draft button" do
        let(:submit_button) { { draft_button: "Save as draft" } }

        it "redirects provider to provider's applications page" do
          patch providers_legal_aid_application_means_capital_disregards_discretionary_path(application), params: params.merge(submit_button)
          expect(response).to redirect_to(in_progress_providers_legal_aid_applications_path)
        end
      end
    end
  end
end
