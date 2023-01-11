require "rails_helper"

RSpec.describe "provider own home requests" do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:provider) { legal_aid_application.provider }

  describe "GET providers/means/own_home" do
    subject { get providers_legal_aid_application_means_own_home_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { subject }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        subject
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "PATCH providers/means/own_home" do
    subject { patch providers_legal_aid_application_means_own_home_path(legal_aid_application), params: params.merge(submit_button) }

    let(:own_home) { "owned_outright" }
    let(:params) do
      {
        legal_aid_application: { own_home: },
      }
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        subject
      end

      context "with Continue button pressed" do
        let(:submit_button) do
          {
            continue_button: "Continue",
          }
        end

        it "updates the record" do
          expect(legal_aid_application.reload.own_home).to eq own_home
        end

        context "when owned outright" do
          it "redirects to the property value page" do
            expect(response).to redirect_to providers_legal_aid_application_means_property_value_path(legal_aid_application)
          end

          it "updates the record to match" do
            expect(legal_aid_application.reload.own_home_owned_outright?).to be_truthy
          end
        end

        context "when mortgaged" do
          let(:own_home) { "mortgage" }

          it "redirects to the property value page" do
            expect(response).to redirect_to providers_legal_aid_application_means_property_value_path(legal_aid_application)
          end

          it "updates the record to match" do
            expect(legal_aid_application.reload.own_home_mortgage?).to be_truthy
          end

          context "when checking answers" do
            let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_passported_state_machine, :checking_passported_answers) }

            it "redirects to next page in the flow" do
              expect(response).to redirect_to(providers_legal_aid_application_means_property_value_path(legal_aid_application))
            end
          end
        end

        context "without own home" do
          let(:own_home) { "no" }

          context "when checking answers" do
            let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_passported_state_machine, :checking_passported_answers) }

            it "redirects to check answers page" do
              expect(response).to redirect_to(providers_legal_aid_application_check_passported_answers_path(legal_aid_application))
            end
          end

          context "with provider checking answers" do
            let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine, :checking_non_passported_means) }

            it "redirects to the checking answers income page" do
              expect(response).to redirect_to(providers_legal_aid_application_means_check_answers_income_path(legal_aid_application))
            end
          end
        end
      end

      context "when Save as draft button pressed" do
        let(:submit_button) { { draft_button: "Save as draft" } }

        it "updates the record" do
          expect(legal_aid_application.reload.own_home).to eq own_home
        end

        context "when owned outright" do
          it "redirects to provider applications home page" do
            expect(response).to redirect_to providers_legal_aid_applications_path
          end

          it "updates the record to match" do
            expect(legal_aid_application.reload.own_home_owned_outright?).to be_truthy
          end
        end

        context "when mortgaged" do
          let(:own_home) { "mortgage" }

          it "redirects to 1b. How much is your client’s home worth" do
            expect(response).to redirect_to providers_legal_aid_applications_path
          end

          it "updates the record to match" do
            expect(legal_aid_application.reload.own_home_mortgage?).to be_truthy
          end

          context "when checking answers" do
            let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :checking_passported_answers) }

            it "redirects to the applications list page" do
              expect(response).to redirect_to(providers_legal_aid_applications_path)
            end
          end
        end

        context "without own home" do
          let(:own_home) { "no" }

          it "redirects to savings or investments question" do
            expect(response).to redirect_to providers_legal_aid_applications_path
          end

          it "updates the record to match" do
            expect(legal_aid_application.reload.own_home_no?).to be_truthy
          end

          context "when checking answers" do
            let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :checking_passported_answers) }

            it "redirects to the applications list page" do
              expect(response).to redirect_to(providers_legal_aid_applications_path)
            end
          end
        end

        context "with nothing specified" do
          let(:params) { {} }

          it "redirects provider to provider's applications page" do
            subject
            expect(response).to redirect_to(providers_legal_aid_applications_path)
          end

          it "does not update the record" do
            expect(legal_aid_application.reload.own_home).to be_nil
          end
        end
      end
    end
  end
end
