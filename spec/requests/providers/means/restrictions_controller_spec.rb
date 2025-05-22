require "rails_helper"

RSpec.describe "provider restrictions request" do
  let(:application) { create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine) }
  let(:provider) { application.provider }

  describe "GET /providers/applications/:id/means/restrictions" do
    subject(:get_request) { get providers_legal_aid_application_means_restrictions_path(application) }

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
    end
  end

  describe "PATCH /providers/applications/:id/means/restrictions" do
    subject(:patch_request) { patch providers_legal_aid_application_means_restrictions_path(application), params: params.merge(submit_button) }

    let(:params) do
      {
        legal_aid_application: {
          has_restrictions:,
          restrictions_details:,
        },
      }
    end
    let(:restrictions_details) { Faker::Lorem.paragraph }
    let(:has_restrictions) { "true" }

    context "when the provider is authenticated" do
      before do
        login_as provider
        patch_request
      end

      context "and the Form is submitted with continue button" do
        let(:submit_button) do
          {
            continue_button: "Continue",
          }
        end

        it "updates legal aid application restriction information" do
          expect(application.reload.has_restrictions).to be true
          expect(application.reload.restrictions_details).not_to be_empty
        end

        context "when the citizen has completed the non-passported path" do
          context "and the calculation date is after the start date" do
            let(:application) do
              create(:legal_aid_application,
                     :with_applicant,
                     :non_passported,
                     :with_non_passported_state_machine,
                     :provider_assessing_means,
                     :with_proceedings,
                     :with_delegated_functions_on_proceedings,
                     explicit_proceedings: [:da004],
                     df_options: { DA004: [1.day.ago, Date.new(2021, 1, 9)] })
            end

            it "redirects to the next page" do
              expect(response).to have_http_status(:redirect)
            end
          end

          context "and the calculation date is before the start date" do
            let(:application) do
              create(:legal_aid_application,
                     :with_applicant,
                     :non_passported,
                     :with_non_passported_state_machine,
                     :provider_assessing_means,
                     :with_proceedings,
                     :with_delegated_functions_on_proceedings,
                     explicit_proceedings: [:da004],
                     df_options: { DA004: [Date.new(2020, 12, 19), Date.new(2020, 12, 19)] })
            end

            it "redirects to the next page" do
              expect(response).to have_http_status(:redirect)
            end
          end
        end

        context "when provider is checking answers on passported route" do
          let(:application) { create(:legal_aid_application, :with_applicant, :passported, :with_passported_state_machine, :checking_passported_answers) }

          it "redirects to the next page" do
            expect(response).to have_http_status(:redirect)
          end
        end

        context "when submitted with invalid params" do
          let(:restrictions_details) { "" }

          it "displays error" do
            expect(response.body).to include(translation_for(:restrictions_details, "blank"))
          end

          context "and there are no params" do
            let(:has_restrictions) { "" }

            it "displays error" do
              expect(response.body).to include(translation_for(:has_restrictions, "blank"))
            end
          end
        end

        context "when the provider is checking answers on nonpassported route" do
          let(:application) { create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine, :checking_non_passported_means) }

          it "redirects to the check capital answers page" do
            patch_request
            expect(response).to redirect_to(providers_legal_aid_application_check_capital_answers_path)
          end
        end
      end

      context "when the Form is submitted with Save as draft button" do
        let(:submit_button) do
          {
            draft_button: "Save as draft",
          }
        end

        describe "after success" do
          before do
            login_as provider
            patch_request
            application.reload
          end

          it "updates the legal_aid_application.restrictions" do
            expect(application.has_restrictions).to be true
            expect(application.restrictions_details).not_to be_empty
          end

          it "redirects to the list of applications" do
            expect(response).to redirect_to in_progress_providers_legal_aid_applications_path
          end
        end
      end
    end
  end

  def translation_for(attr, error)
    I18n.t("activemodel.errors.models.legal_aid_application.attributes.#{attr}.#{error}")
  end
end
