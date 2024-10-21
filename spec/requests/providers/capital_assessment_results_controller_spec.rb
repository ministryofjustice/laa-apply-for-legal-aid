require "rails_helper"

RSpec.describe Providers::CapitalAssessmentResultsController do
  let(:login_provider) { login_as legal_aid_application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/capital_assessment_result" do
    subject(:get_request) { get providers_legal_aid_application_capital_assessment_result_path(legal_aid_application) }

    let(:cfe_result) { create(:cfe_v6_result) }
    let(:legal_aid_application) { cfe_result.legal_aid_application }
    let!(:applicant) { create(:applicant, with_bank_accounts: 2, legal_aid_application:) }
    let(:applicant_name) { legal_aid_application.applicant_full_name }
    let(:locale_scope) { "shared.assessment_results" }
    let(:add_policy_disregards?) { false }
    let(:add_restrictions?) { false }

    let(:before_tasks) do
      create(:policy_disregards, :with_selected_value, legal_aid_application:) if add_policy_disregards?

      Setting.setting.update!(manually_review_all_cases: false)
      login_provider
      get_request
    end

    before { before_tasks }

    context "with no restrictions" do
      context "and no policy disregards" do
        context "when eligible" do
          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays the correct result" do
            expect(unescaped_response_body).to include(I18n.t("eligible.heading", name: applicant_name, scope: locale_scope))
          end
        end

        context "when ineligible and disposable capital is above the upper threshold" do
          let(:cfe_result) { create(:cfe_v6_result, :ineligible_capital) }

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays the correct result" do
            expect(unescaped_response_body).to include("#{applicant_name} is unlikely to get legal aid")
          end

          it "displays the correct reason" do
            expect(unescaped_response_body).to include("This is because they have too much disposable capital")
          end
        end

        context "when capital contribution required" do
          let(:cfe_result) { create(:cfe_v3_result, :with_capital_contribution_required) }

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays the correct result" do
            expect(unescaped_response_body).to include(I18n.t("capital_contribution_required.heading", name: applicant_name, scope: locale_scope))
          end
        end
      end

      context "with policy disregards" do
        let(:add_policy_disregards?) { true }

        context "when eligible" do
          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays the correct result" do
            expect(unescaped_response_body).to include(I18n.t("eligible.heading", name: applicant_name, scope: locale_scope))
          end
        end

        context "when capital contribution required" do
          let(:cfe_result) { create(:cfe_v3_result, :with_capital_contribution_required) }

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays the correct result" do
            expect(unescaped_response_body).to include(I18n.t("manual_check_required.heading", name: applicant_name, scope: locale_scope))
            expect(unescaped_response_body).to include("We calculated that your client should pay towards legal aid, but the " \
                                                       "amount may change because they received disregarded scheme or charity payments.")
          end
        end
      end
    end

    context "with restrictions" do
      let(:before_tasks) do
        create(:policy_disregards, :with_selected_value, legal_aid_application:) if add_policy_disregards?

        Setting.setting.update!(manually_review_all_cases: false)
        create(:applicant, legal_aid_application:, first_name: "Stepriponikas", last_name: "Bonstart")
        legal_aid_application.update! has_restrictions: true, restrictions_details: "Blah blah"
        login_provider
        get_request
      end

      context "with policy disregards" do
        let(:add_policy_disregards?) { true }

        context "when eligible" do
          let(:cfe_result) { create(:cfe_v3_result, :eligible) }

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays the correct result" do
            expect(unescaped_response_body).to include(I18n.t("eligible.heading", name: applicant_name, scope: locale_scope))
          end
        end

        context "when contribution required" do
          let(:cfe_result) { create(:cfe_v3_result, :with_capital_contribution_required) }

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays manual check required" do
            expect(unescaped_response_body).to include(I18n.t("manual_check_required.heading", name: applicant_name, scope: locale_scope))
            expect(unescaped_response_body).to include("We calculated that your client should pay towards legal aid, but the " \
                                                       "amount may change because:")
            expect(unescaped_response_body).to include("they received disregarded scheme or charity payments")
            expect(unescaped_response_body).to include("they're prohibited from selling or borrowing against their assets")
          end
        end
      end

      context "with no policy disregards" do
        context "when eligible" do
          let(:cfe_result) { create(:cfe_v3_result, :eligible) }

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays the correct result" do
            expect(unescaped_response_body).to include(I18n.t("eligible.heading", name: applicant_name, scope: locale_scope))
          end
        end

        context "when contribution required" do
          let(:cfe_result) { create(:cfe_v3_result, :with_capital_contribution_required) }

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays manual check required" do
            expect(unescaped_response_body).to include(I18n.t("manual_check_required.heading", name: applicant_name, scope: locale_scope))
            expect(unescaped_response_body).to include("We calculated that your client should pay towards legal aid, but the " \
                                                       "amount may change because they're prohibited from selling or borrowing against their assets.")
          end
        end
      end
    end

    context "with extra employment information" do
      let(:before_tasks) do
        applicant.update! extra_employment_information: true, extra_employment_information_details: "Blah blah"
        create(:policy_disregards, :with_selected_value, legal_aid_application:) if add_policy_disregards?
        legal_aid_application.update! has_restrictions: true, restrictions_details: "Blah blah" if add_restrictions?
        login_provider
        get_request
      end

      context "when eligible" do
        let(:cfe_result) { create(:cfe_v4_result, :eligible) }

        it "returns http success" do
          expect(response).to have_http_status(:ok)
        end

        it "displays the correct result" do
          expect(unescaped_response_body).to include(I18n.t("manual_check_required.heading", name: applicant_name, scope: locale_scope))
          expect(unescaped_response_body).to include("We calculated that your client does not need to pay towards legal " \
                                                     "aid, but this may change because you entered further details about " \
                                                     "their employment.")
        end
      end

      context "when capital contribution required" do
        let(:cfe_result) { create(:cfe_v4_result, :with_capital_contribution_required) }
        let(:add_policy_disregards?) { false }

        it "returns http success" do
          expect(response).to have_http_status(:ok)
        end

        it "displays the correct result" do
          expect(unescaped_response_body).to include(I18n.t("manual_check_required.heading", name: applicant_name, scope: locale_scope))
          expect(unescaped_response_body).to include("We calculated that your client should pay towards legal aid, but the " \
                                                     "amount may change because you entered further details about their " \
                                                     "employment.")
        end

        context "with policy disregards" do
          let(:add_policy_disregards?) { true }

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays the correct result" do
            expect(unescaped_response_body).to include(I18n.t("manual_check_required.heading", name: applicant_name, scope: locale_scope))
            expect(unescaped_response_body).to include("We calculated that your client should pay towards legal aid, but the " \
                                                       "amount may change because:")
            expect(unescaped_response_body).to include("they received disregarded scheme or charity payments")
            expect(unescaped_response_body).to include("you entered further details about their employment")
          end
        end

        context "with policy disregards and with restrictions" do
          let(:add_policy_disregards?) { true }
          let(:add_restrictions?) { true }

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays the correct result" do
            expect(unescaped_response_body).to include(I18n.t("manual_check_required.heading", name: applicant_name, scope: locale_scope))
            expect(unescaped_response_body).to include("We calculated that your client should pay towards legal aid, but the " \
                                                       "amount may change because:")
            expect(unescaped_response_body).to include("they received disregarded scheme or charity payments")
            expect(unescaped_response_body).to include("they're prohibited from selling or borrowing against their assets")
            expect(unescaped_response_body).to include("you entered further details about their employment")
          end
        end
      end
    end

    context "when unauthenticated" do
      let(:before_tasks) { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "with unknown result" do
      let(:cfe_result) { create(:cfe_v3_result, result: {}.to_json) }
      let(:before_tasks) { login_provider }

      it "raises error" do
        expect { get_request }.to raise_error(/Unknown capital_assessment_result/)
      end
    end
  end

  describe "PATCH /providers/applications/:id/capital_assessment_result" do
    subject(:patch_request) { patch providers_legal_aid_application_capital_assessment_result_path(legal_aid_application), params: params.merge(submit_button) }

    let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
    let(:params) { {} }

    context "when the provider is authenticated" do
      before do
        allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(true)
        login_provider
        patch_request
      end

      context "when continue button is pressed" do
        let(:submit_button) { { continue_button: "Continue" } }

        it "redirects to the next page" do
          expect(response).to have_http_status(:redirect)
        end
      end

      context "when save as draft button is pressed" do
        let(:submit_button) { { draft_button: "Save as draft" } }

        it "redirects provider to provider's applications page" do
          patch_request
          expect(response).to redirect_to(submitted_providers_legal_aid_applications_path)
        end

        it "sets the application as draft" do
          expect(legal_aid_application.reload).to be_draft
        end
      end
    end
  end
end
