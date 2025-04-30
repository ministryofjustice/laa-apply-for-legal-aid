require "rails_helper"

RSpec.describe Providers::CapitalIncomeAssessmentResultsController do
  include ActionView::Helpers::NumberHelper
  let(:login_provider) { login_as legal_aid_application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/capital_income_assessment_result" do
    subject(:get_request) { get providers_legal_aid_application_capital_income_assessment_result_path(legal_aid_application) }

    let(:legal_aid_application) { cfe_result.legal_aid_application }
    let(:applicant_name) { legal_aid_application.applicant_full_name }
    let(:locale_scope) { "shared.assessment_results" }
    let(:add_policy_disregards?) { false }
    let(:add_restrictions?) { false }

    let(:before_tasks) do
      create(:applicant, with_bank_accounts: 2, legal_aid_application:)
      create(:policy_disregards, :with_selected_value, legal_aid_application:) if add_policy_disregards?
      Setting.setting.update!(manually_review_all_cases: false)
      login_provider
      get_request
    end

    before { before_tasks }

    context "with no restrictions" do
      context "without policy disregards" do
        context "when eligible" do
          let(:cfe_result) { create(:cfe_v6_result, :eligible) }

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays the correct result" do
            expect(unescaped_response_body).to include(I18n.t("eligible.heading", name: applicant_name, scope: locale_scope))
          end
        end

        context "when not eligible" do
          context "when ineligible and gross income is above the upper threshold" do
            let(:cfe_result) { create(:cfe_v6_result, :ineligible_gross_income) }

            it "returns http success" do
              expect(response).to have_http_status(:ok)
            end

            it "displays the correct result" do
              expect(unescaped_response_body).to include("#{applicant_name} is unlikely to get legal aid")
            end

            it "displays the correct reason" do
              expect(unescaped_response_body).to include("This is because they have too much gross income")
            end
          end

          context "when ineligible and disposable income is above the upper threshold" do
            let(:cfe_result) { create(:cfe_v6_result, :ineligible_disposable_income) }

            it "returns http success" do
              expect(response).to have_http_status(:ok)
            end

            it "displays the correct result" do
              expect(unescaped_response_body).to include("#{applicant_name} is unlikely to get legal aid")
            end

            it "displays the correct reason" do
              expect(unescaped_response_body).to include("This is because they have too much disposable income")
            end
          end
        end

        context "when capital contribution required" do
          let(:cfe_result) { create(:cfe_v6_result, :with_capital_contribution_required) }

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays the correct result" do
            expect(unescaped_response_body).to include(I18n.t("capital_contribution_required.heading", name: applicant_name, scope: locale_scope))
          end
        end

        context "when income contribution required" do
          let(:cfe_result) { create(:cfe_v6_result, :with_income_contribution_required) }

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays the correct result" do
            expect(unescaped_response_body).to include(I18n.t("income_contribution_required.heading", name: applicant_name, scope: locale_scope))
          end
        end

        context "when both income and capital contribution required" do
          let(:cfe_result) { create(:cfe_v6_result, :with_capital_and_income_contributions_required) }

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays the correct result" do
            income = gds_number_to_currency(cfe_result.income_contribution)
            income_string = "#{income} per month from their disposable income until the end of the case or there is a change in their financial situation"
            expect(unescaped_response_body).to include(I18n.t("capital_and_income_contribution_required.heading", name: applicant_name, scope: locale_scope))
            expect(unescaped_response_body).to include(income_string)
            expect(unescaped_response_body).to include("a #{gds_number_to_currency(cfe_result.capital_contribution)} one-off payment from their disposable capital")
            expect(unescaped_response_body).to include("Total outgoings (includes tax and National Insurance)")
            expect(unescaped_response_body).to include("Total deductions (includes employment expenses)")
          end
        end
      end

      context "with policy disregards" do
        let(:add_policy_disregards?) { true }

        context "when eligible" do
          let(:cfe_result) { create(:cfe_v6_result, :eligible) }

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays the correct result" do
            expect(unescaped_response_body).to include(I18n.t("eligible.heading", name: applicant_name, scope: locale_scope))
          end
        end

        context "when not eligible" do
          let(:cfe_result) { create(:cfe_v6_result, :ineligible_gross_income) }

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays the correct result" do
            expect(unescaped_response_body).to include("#{applicant_name} is unlikely to get legal aid")
          end
        end

        context "when capital contribution required" do
          let(:cfe_result) { create(:cfe_v6_result, :with_capital_contribution_required) }

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays the correct result" do
            expect(unescaped_response_body).to include(I18n.t("manual_check_required.heading", name: applicant_name, scope: locale_scope))
            expect(unescaped_response_body).to include("We calculated that your client should pay towards legal aid, but the " \
                                                       "amount may change because they received disregarded scheme or charity payments.")
          end
        end

        context "when income contribution required" do
          let(:cfe_result) { create(:cfe_v6_result, :with_income_contribution_required) }

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays the correct result" do
            expect(unescaped_response_body).to include(I18n.t("manual_check_required.heading", name: applicant_name, scope: locale_scope))
            expect(unescaped_response_body).to include("We calculated that your client should pay towards legal aid, but the " \
                                                       "amount may change because they received disregarded scheme or charity payments.")
          end
        end

        context "when both income and capital contribution required" do
          let(:cfe_result) { create(:cfe_v6_result, :with_capital_and_income_contributions_required) }

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
        Setting.setting.update!(manually_review_all_cases: false)
        create(:applicant, legal_aid_application:, first_name: "Stepriponikas", last_name: "Bonstart")
        create(:policy_disregards, :with_selected_value, legal_aid_application:) if add_policy_disregards?
        legal_aid_application.update! has_restrictions: true, restrictions_details: "Blah blah"
        login_provider
        get_request
      end

      context "without policy disregards" do
        context "when eligible" do
          let(:cfe_result) { create(:cfe_v6_result, :eligible) }

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays the correct result" do
            expect(unescaped_response_body).to include(I18n.t("eligible.heading", name: applicant_name, scope: locale_scope))
          end
        end

        context "when capital contribution required" do
          let(:cfe_result) { create(:cfe_v6_result, :with_capital_contribution_required) }

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays manual check required" do
            expect(unescaped_response_body).to include(I18n.t("manual_check_required.heading", name: applicant_name, scope: locale_scope))
            expect(unescaped_response_body).to include("We calculated that your client should pay towards legal aid, but the " \
                                                       "amount may change because they're prohibited from selling or borrowing against their assets.")
          end
        end

        context "when income contribution required" do
          let(:cfe_result) { create(:cfe_v6_result, :with_income_contribution_required) }

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays manual check required" do
            expect(unescaped_response_body).to include(I18n.t("manual_check_required.heading", name: applicant_name, scope: locale_scope))
            expect(unescaped_response_body).to include("We calculated that your client should pay towards legal aid, but the " \
                                                       "amount may change because they're prohibited from selling or borrowing against their assets.")
          end
        end

        context "when both income and capital contribution required" do
          let(:cfe_result) { create(:cfe_v6_result, :with_capital_and_income_contributions_required) }

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

      context "with policy disregards" do
        let(:add_policy_disregards?) { true }

        context "when eligible" do
          let(:cfe_result) { create(:cfe_v6_result, :eligible) }

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays the correct result" do
            expect(unescaped_response_body).to include(I18n.t("eligible.heading", name: applicant_name, scope: locale_scope))
          end
        end

        context "when capital contribution required" do
          let(:cfe_result) { create(:cfe_v6_result, :with_capital_contribution_required) }

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays manual check because of disregards and restrictions" do
            expect(unescaped_response_body).to include(I18n.t("manual_check_required.heading", name: applicant_name, scope: locale_scope))
            expect(unescaped_response_body).to include("We calculated that your client should pay towards legal aid, but the " \
                                                       "amount may change because:")
            expect(unescaped_response_body).to include("they received disregarded scheme or charity payments")
            expect(unescaped_response_body).to include("they're prohibited from selling or borrowing against their assets")
          end
        end

        context "when income contribution required" do
          let(:cfe_result) { create(:cfe_v6_result, :with_income_contribution_required) }

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays manual check because of disregards and restrictions" do
            expect(unescaped_response_body).to include(I18n.t("manual_check_required.heading", name: applicant_name, scope: locale_scope))
            expect(unescaped_response_body).to include("We calculated that your client should pay towards legal aid, but the " \
                                                       "amount may change because:")
            expect(unescaped_response_body).to include("they received disregarded scheme or charity payments")
            expect(unescaped_response_body).to include("they're prohibited from selling or borrowing against their assets")
          end
        end

        context "when both income and capital contribution required" do
          let(:cfe_result) { create(:cfe_v6_result, :with_capital_and_income_contributions_required) }

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays manual check because of disregards and restrictions" do
            expect(unescaped_response_body).to include(I18n.t("manual_check_required.heading", name: applicant_name, scope: locale_scope))
            expect(unescaped_response_body).to include("We calculated that your client should pay towards legal aid, but the " \
                                                       "amount may change because:")
            expect(unescaped_response_body).to include("they received disregarded scheme or charity payments")
            expect(unescaped_response_body).to include("they're prohibited from selling or borrowing against their assets")
          end
        end
      end
    end

    context "with extra employment information" do
      let(:before_tasks) do
        create(:applicant, :with_extra_employment_information, legal_aid_application:)
        create(:policy_disregards, :with_selected_value, legal_aid_application:) if add_policy_disregards?
        legal_aid_application.update! has_restrictions: true, restrictions_details: "Blah blah" if add_restrictions?
        login_provider
        get_request
      end

      context "when eligible" do
        let(:cfe_result) { create(:cfe_v6_result, :eligible) }

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
        let(:cfe_result) { create(:cfe_v6_result, :with_capital_contribution_required) }

        it "returns http success" do
          expect(response).to have_http_status(:ok)
        end

        it "displays the correct result" do
          expect(unescaped_response_body).to include(I18n.t("manual_check_required.heading", name: applicant_name, scope: locale_scope))
          expect(unescaped_response_body).to include("We calculated that your client should pay towards legal aid, but the " \
                                                     "amount may change because you entered further details about their " \
                                                     "employment.")
        end
      end

      context "when income contribution required" do
        let(:cfe_result) { create(:cfe_v6_result, :with_income_contribution_required) }

        it "returns http success" do
          expect(response).to have_http_status(:ok)
        end

        it "displays the correct result" do
          expect(unescaped_response_body).to include(I18n.t("manual_check_required.heading", name: applicant_name, scope: locale_scope))
          expect(unescaped_response_body).to include("We calculated that your client should pay towards legal aid, but the " \
                                                     "amount may change because you entered further details about their " \
                                                     "employment.")
        end
      end

      context "when both income and capital contribution required" do
        let(:cfe_result) { create(:cfe_v6_result, :with_capital_and_income_contributions_required) }

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
      let(:cfe_result) { create(:cfe_v6_result, :eligible) }

      it_behaves_like "a provider not authenticated"
    end

    context "with unknown result" do
      let(:cfe_result) { create(:cfe_v6_result, result: { result_summary: { overall_result: { result: "foobar" } } }.to_json) }
      let(:before_tasks) { login_provider }

      it "raises error" do
        expect { get_request }.to raise_error(/Unknown result using #{described_class}: 'foobar'/)
      end
    end

    context "when applicant has employment(s)" do
      let(:cfe_result) { create(:cfe_v6_result, :with_employments) }
      let(:td) { "</th><td class=\"govuk-table__cell govuk-table__cell--numeric\">" }
      let(:footer_td) { "</th><td class=\"govuk-table__footer govuk-table__footer--numeric\">" }
      let(:monthly_income_before_tax) { I18n.t("providers.capital_income_assessment_results.employment_income.monthly_income_before_tax") }
      let(:benefits_in_kind) { I18n.t("providers.capital_income_assessment_results.employment_income.benefits_in_kind") }
      let(:tax) { I18n.t("providers.capital_income_assessment_results.employment_income.tax") }
      let(:national_insurance) { I18n.t("providers.capital_income_assessment_results.employment_income.national_insurance") }
      let(:fixed_employment_deduction) { I18n.t("providers.capital_income_assessment_results.employment_income.fixed_employment_deduction") }
      let(:total_employment) { I18n.t("providers.capital_income_assessment_results.employment_income.total") }
      let(:total_outgoings) { I18n.t("providers.capital_income_assessment_results.outgoings.total_outgoings") }
      let(:total_other_income) { I18n.t("providers.capital_income_assessment_results.other_income.total") }
      let(:total_deductions) { I18n.t("providers.capital_income_assessment_results.deductions.total_deductions") }
      let(:total_disposable_income) { I18n.t("providers.capital_income_assessment_results.disposable_income.total_income") }
      let(:total_disposable_outgoings) { I18n.t("providers.capital_income_assessment_results.disposable_income.total_outgoings") }
      let(:total_disposable_deductions) { I18n.t("providers.capital_income_assessment_results.disposable_income.total_deductions") }
      let(:total_disposable) { I18n.t("providers.capital_income_assessment_results.disposable_income.total_disposable") }

      it "displays the employment income" do
        expect(unescaped_response_body).to include(I18n.t("providers.capital_income_assessment_results.other_income.title", individual: "Client"))
        expect(unescaped_response_body).to include(I18n.t("providers.capital_income_assessment_results.employment_income.title", individual: "Client"))
        expect(unescaped_response_body).to include(monthly_income_before_tax + td + gds_number_to_currency(cfe_result.employment_income_gross_income))
        expect(unescaped_response_body).to include(benefits_in_kind + td + gds_number_to_currency(cfe_result.employment_income_benefits_in_kind))
        expect(unescaped_response_body).to include(tax + td + gds_number_to_currency(cfe_result.employment_income_tax))
        expect(unescaped_response_body).to include(national_insurance + td + gds_number_to_currency(cfe_result.employment_income_national_insurance))
        expect(unescaped_response_body).to include(fixed_employment_deduction + td + gds_number_to_currency(cfe_result.employment_income_fixed_employment_deduction))
        expect(unescaped_response_body).to include(total_employment + footer_td + gds_number_to_currency(cfe_result.employment_income_net_employment_income))
      end

      it "displays the correct totals" do
        expect(unescaped_response_body).to include(total_outgoings + footer_td + gds_number_to_currency(cfe_result.total_monthly_outgoings))
        expect(unescaped_response_body).to include(total_other_income + footer_td + gds_number_to_currency(cfe_result.total_monthly_income))
        expect(unescaped_response_body).to include(total_deductions + footer_td + gds_number_to_currency(cfe_result.total_deductions))
        expect(unescaped_response_body).to include(total_disposable_income + td + gds_number_to_currency(cfe_result.total_monthly_income_including_employment_income))
        expect(unescaped_response_body).to include(total_disposable_outgoings + td + gds_number_to_currency(cfe_result.total_monthly_outgoings_including_tax_and_ni))
        expect(unescaped_response_body).to include(total_disposable_deductions + td + gds_number_to_currency(cfe_result.total_deductions_including_fixed_employment_allowance))
        expect(unescaped_response_body).to include(total_disposable + footer_td + gds_number_to_currency(cfe_result.total_disposable_income_assessed))
      end
    end

    context "when applicant has no employment(s)" do
      let(:cfe_result) { create(:cfe_v6_result, :with_no_employments) }

      it "does not display employment income" do
        expect(unescaped_response_body).not_to include(I18n.t("providers.capital_income_assessment_results.employment_income.title", individual: "Client"))
        expect(unescaped_response_body).to include(I18n.t("providers.capital_income_assessment_results.other_income.income", individual: "Client"))
      end
    end
  end

  describe "PATCH /providers/applications/:id/capital_income_assessment_result" do
    subject(:patch_request) { patch providers_legal_aid_application_capital_income_assessment_result_path(legal_aid_application), params: params.merge(submit_button) }

    let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
    let(:params) { {} }

    context "when the provider is authenticated" do
      before do
        login_provider
        patch_request
      end

      context "when the continue button is pressed" do
        let(:submit_button) { { continue_button: "Continue" } }

        it "redirects to the next page" do
          expect(response).to have_http_status(:redirect)
        end
      end

      context "when the save as draft button is pressed" do
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
