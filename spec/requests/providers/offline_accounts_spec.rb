require "rails_helper"

RSpec.describe "providers offine accounts" do
  let(:application) { create(:legal_aid_application, :with_applicant, :with_savings_amount) }
  let(:savings_amount) { application.savings_amount }

  describe "GET /providers/applications/:legal_aid_application_id/offline_account" do
    subject(:get_request) { get providers_legal_aid_application_offline_account_path(application) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as application.provider
      end

      it "returns http success" do
        get_request
        expect(response).to have_http_status(:ok)
      end

      it "does not show bank account details" do
        get_request
        expect(response.body).not_to match("Account number")
      end

      describe "back link" do
        context "when applicant does not own home" do
          before { get providers_legal_aid_application_means_own_home_path(application) }

          it "points to the own home page" do
            get_request
            expect(response.body).to have_back_link(providers_legal_aid_application_means_own_home_path(application, back: true))
          end
        end

        context "when applicant owns home" do
          before { get providers_legal_aid_application_means_property_details_path(application) }

          it "redirects to property details page" do
            get_request
            expect(response.body).to have_back_link(providers_legal_aid_application_means_property_details_path(application, back: true))
          end
        end
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/savings_and_investment" do
    subject(:patch_request) { patch providers_legal_aid_application_offline_account_path(application), params: params.merge(submit_button) }

    let(:offline_current_accounts) { rand(1...1_000_000.0).round(2).to_s }
    let(:check_box_offline_current_accounts) { "true" }
    let(:params) do
      {
        savings_amount: {
          offline_current_accounts:,
          check_box_offline_current_accounts:,
        },
      }
    end

    context "when the provider is authenticated" do
      before do
        login_as application.provider
      end

      context "when submitted with Continue button" do
        let(:submit_button) do
          {
            continue_button: "Continue",
          }
        end

        context "when not in checking passported answers state" do
          it "updates the offline_current_accounts amount" do
            expect { patch_request }.to change { savings_amount.reload.offline_current_accounts.to_s }.to(offline_current_accounts)
          end

          it "does not displays an error" do
            patch_request
            expect(response.body).not_to match("govuk-error-message")
            expect(response.body).not_to match("govuk-form-group--error")
          end

          it "redirects to the next step" do
            patch_request
            expect(response).to have_http_status(:redirect)
          end

          context "when 'none of these' checkbox is selected" do
            let(:params) { { savings_amount: { no_account_selected: "true" } } }

            it "sets no_account_selected to true" do
              patch_request
              expect(savings_amount.reload.no_account_selected).to be(true)
            end
          end

          context "with invalid input" do
            let(:offline_current_accounts) { "fifty" }

            it "renders successfully" do
              patch_request
              expect(response).to have_http_status(:ok)
            end

            it "displays an error" do
              patch_request
              expect(response.body).to have_content("Enter the amount in current accounts, like 1,000 or 20.30")
              expect(response.body).to match("govuk-error-message")
              expect(response.body).to match("govuk-form-group--error")
            end
          end
        end

        context "when in checking citizen answers state" do
          let(:state) { :checking_citizen_answers }
          let(:application) { create(:legal_aid_application, :with_applicant, :with_savings_amount, :with_non_passported_state_machine, state) }
          let(:submit_button) do
            {
              continue_button: "Continue",
            }
          end

          before { patch_request }

          it "redirects to the next page" do
            expect(response).to have_http_status(:redirect)
          end

          context "with no savings" do
            let(:offline_current_accounts) { 0 }
            let(:offline_savings_accounts) { 0 }

            it "redirects to the next page" do
              expect(response).to have_http_status(:redirect)
            end

            context "when provider_entering_merits" do
              let(:state) { :provider_entering_merits }

              it "redirects to the next page" do
                expect(response).to have_http_status(:redirect)
              end
            end
          end
        end
      end

      context "when submitted with Save as draft button" do
        let(:submit_button) do
          {
            draft_button: "Save as draft",
          }
        end

        it "updates the offline_current_accounts amount" do
          expect { patch_request }.to change { savings_amount.reload.offline_current_accounts.to_s }.to(offline_current_accounts)
        end

        it "does not displays an error" do
          patch_request
          expect(response.body).not_to match("govuk-error-message")
          expect(response.body).not_to match("govuk-form-group--error")
        end

        it "redirects to the provider applications page" do
          patch_request
          expect(response).to redirect_to(in_progress_providers_legal_aid_applications_path)
        end

        context "with invalid input" do
          let(:offline_current_accounts) { "fifty" }

          it "renders successfully" do
            patch_request
            expect(response).to have_http_status(:ok)
          end

          it "displays an error" do
            patch_request
            expect(response.body).to have_content("Enter the amount in current accounts, like 1,000 or 20.30")
            expect(response.body).to match("govuk-error-message")
            expect(response.body).to match("govuk-form-group--error")
          end
        end
      end
    end
  end
end
