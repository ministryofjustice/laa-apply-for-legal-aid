require 'rails_helper'

RSpec.describe Providers::CapitalIncomeAssessmentResultsController, type: :request do
  include ActionView::Helpers::NumberHelper
  let(:login_provider) { login_as legal_aid_application.provider }

  describe 'GET  /providers/applications/:legal_aid_application_id/capital_income_assessment_result' do
    let!(:applicant) { create :applicant, with_bank_accounts: 2, legal_aid_application: legal_aid_application }
    let(:legal_aid_application) { cfe_result.legal_aid_application }
    let(:applicant_name) { legal_aid_application.applicant_full_name }
    let(:locale_scope) { 'shared.assessment_results' }
    let(:add_policy_disregards?) { false }

    let(:before_tasks) do
      create(:policy_disregards, :with_selected_value, legal_aid_application: legal_aid_application) if add_policy_disregards?

      Setting.setting.update!(manually_review_all_cases: false)
      login_provider
      subject
    end

    subject { get providers_legal_aid_application_capital_income_assessment_result_path(legal_aid_application) }

    before { before_tasks }

    context 'no restrictions' do
      context 'without policy disregards' do
        context 'eligible' do
          let!(:cfe_result) { create :cfe_v3_result, :eligible }
          it 'returns http success' do
            expect(response).to have_http_status(:ok)
          end

          it 'displays the correct result' do
            expect(unescaped_response_body).to include(I18n.t('eligible.heading', name: applicant_name, scope: locale_scope))
          end
        end

        context 'when not eligible' do
          let!(:cfe_result) { create :cfe_v3_result, :not_eligible }

          it 'returns http success' do
            expect(response).to have_http_status(:ok)
          end

          it 'displays the correct result' do
            expect(unescaped_response_body).to include(I18n.t('not_eligible.heading', name: applicant_name, scope: locale_scope))
          end
        end

        context 'when capital contribution required' do
          let(:cfe_result) { create :cfe_v3_result, :with_capital_contribution_required }

          it 'returns http success' do
            expect(response).to have_http_status(:ok)
          end

          it 'displays the correct result' do
            expect(unescaped_response_body).to include(I18n.t('capital_contribution_required.heading', name: applicant_name, scope: locale_scope))
          end
        end

        context 'when income contribution required' do
          let(:cfe_result) { create :cfe_v3_result, :with_income_contribution_required }

          it 'returns http success' do
            expect(response).to have_http_status(:ok)
          end

          it 'displays the correct result' do
            expect(unescaped_response_body).to include(I18n.t('income_contribution_required.heading', name: applicant_name, scope: locale_scope))
          end
        end

        context 'when both income and capital contribution required' do
          let(:cfe_result) { create :cfe_v3_result, :with_capital_and_income_contributions_required }

          it 'returns http success' do
            expect(response).to have_http_status(:ok)
          end

          it 'displays the correct result' do
            expect(unescaped_response_body).to include(I18n.t('capital_and_income_contribution_required.heading', name: applicant_name, scope: locale_scope))
            expect(unescaped_response_body).to include("#{gds_number_to_currency(cfe_result.income_contribution)} from their disposable income")
            expect(unescaped_response_body).to include("#{gds_number_to_currency(cfe_result.capital_contribution)} from their disposable capital")
          end
        end
      end

      context 'with policy disregards' do
        let(:add_policy_disregards?) { true }

        context 'eligible' do
          let!(:cfe_result) { create :cfe_v3_result, :eligible }
          it 'returns http success' do
            expect(response).to have_http_status(:ok)
          end

          it 'displays the correct result' do
            expect(unescaped_response_body).to include(I18n.t('eligible.heading', name: applicant_name, scope: locale_scope))
          end
        end

        context 'when not eligible' do
          let!(:cfe_result) { create :cfe_v3_result, :not_eligible }

          it 'returns http success' do
            expect(response).to have_http_status(:ok)
          end

          it 'displays the correct result' do
            expect(unescaped_response_body).to include(I18n.t('not_eligible.heading', name: applicant_name, scope: locale_scope))
          end
        end

        context 'when capital contribution required' do
          let(:cfe_result) { create :cfe_v3_result, :with_capital_contribution_required }

          it 'returns http success' do
            expect(response).to have_http_status(:ok)
          end

          it 'displays the correct result' do
            expect(unescaped_response_body).to include(I18n.t('manual_check_disregards.heading', name: applicant_name, scope: locale_scope))
          end
        end

        context 'when income contribution required' do
          let(:cfe_result) { create :cfe_v3_result, :with_income_contribution_required }

          it 'returns http success' do
            expect(response).to have_http_status(:ok)
          end

          it 'displays the correct result' do
            expect(unescaped_response_body).to include(I18n.t('manual_check_disregards.heading', name: applicant_name, scope: locale_scope))
          end
        end

        context 'when both income and capital contribution required' do
          let(:cfe_result) { create :cfe_v3_result, :with_capital_and_income_contributions_required }

          it 'returns http success' do
            expect(response).to have_http_status(:ok)
          end

          it 'displays the correct result' do
            expect(unescaped_response_body).to include(I18n.t('manual_check_disregards.heading', name: applicant_name, scope: locale_scope))
          end
        end
      end
    end

    context 'with restrictions' do
      let(:before_tasks) do
        Setting.setting.update!(manually_review_all_cases: false)
        create :applicant, legal_aid_application: legal_aid_application, first_name: 'Stepriponikas', last_name: 'Bonstart'
        create(:policy_disregards, :with_selected_value, legal_aid_application: legal_aid_application) if add_policy_disregards?
        legal_aid_application.update has_restrictions: true, restrictions_details: 'Blah blah'
        login_provider
        subject
      end

      context 'without policy disregards' do
        context 'eligible' do
          let!(:cfe_result) { create :cfe_v3_result, :eligible }
          it 'returns http success' do
            expect(response).to have_http_status(:ok)
          end

          it 'displays the correct result' do
            expect(unescaped_response_body).to include(I18n.t('manual_check_required.heading', name: applicant_name, scope: locale_scope))
          end
        end

        context 'when capital contribution required' do
          let(:cfe_result) { create :cfe_v3_result, :with_capital_contribution_required }

          it 'returns http success' do
            expect(response).to have_http_status(:ok)
          end

          it 'displays manual check required' do
            expect(unescaped_response_body).to include(I18n.t('manual_check_required.heading', name: applicant_name, scope: locale_scope))
          end
        end

        context 'when income contribution required' do
          let(:cfe_result) { create :cfe_v3_result, :with_income_contribution_required }

          it 'returns http success' do
            expect(response).to have_http_status(:ok)
          end

          it 'displays manual check required' do
            expect(unescaped_response_body).to include(I18n.t('manual_check_required.heading', name: applicant_name, scope: locale_scope))
          end
        end

        context 'when both income and capital contribution required' do
          let(:cfe_result) { create :cfe_v3_result, :with_capital_and_income_contributions_required }

          it 'returns http success' do
            expect(response).to have_http_status(:ok)
          end

          it 'displays manual check required' do
            expect(unescaped_response_body).to include(I18n.t('manual_check_required.heading', name: applicant_name, scope: locale_scope))
          end
        end
      end

      context 'with policy disregards' do
        let(:add_policy_disregards?) { true }

        context 'eligible' do
          let!(:cfe_result) { create :cfe_v3_result, :eligible }
          it 'returns http success' do
            expect(response).to have_http_status(:ok)
          end

          it 'displays the correct result' do
            expect(unescaped_response_body).to include(I18n.t('manual_check_disregards.heading', name: applicant_name, scope: locale_scope))
          end
        end

        context 'when capital contribution required' do
          let(:cfe_result) { create :cfe_v3_result, :with_capital_contribution_required }

          it 'returns http success' do
            expect(response).to have_http_status(:ok)
          end

          it 'displays manual check because of disregards and restrictions' do
            expect(unescaped_response_body).to include(I18n.t('manual_check_disregards_restrictions.heading', name: applicant_name, scope: locale_scope))
          end
        end

        context 'when income contribution required' do
          let(:cfe_result) { create :cfe_v3_result, :with_income_contribution_required }

          it 'returns http success' do
            expect(response).to have_http_status(:ok)
          end

          it 'displays manual check because of disregards and restrictions' do
            expect(unescaped_response_body).to include(I18n.t('manual_check_disregards_restrictions.heading', name: applicant_name, scope: locale_scope))
          end
        end

        context 'when both income and capital contribution required' do
          let(:cfe_result) { create :cfe_v3_result, :with_capital_and_income_contributions_required }

          it 'returns http success' do
            expect(response).to have_http_status(:ok)
          end

          it 'displays manual check because of disregards and restrictions' do
            expect(unescaped_response_body).to include(I18n.t('manual_check_disregards_restrictions.heading', name: applicant_name, scope: locale_scope))
          end
        end
      end
    end

    context 'unauthenticated' do
      let(:before_tasks) { subject }
      let!(:cfe_result) { create :cfe_v3_result, :eligible }
      it_behaves_like 'a provider not authenticated'
    end

    context 'unknown result' do
      let(:cfe_result) { create :cfe_v3_result, result: {}.to_json }
      let(:before_tasks) do
        login_provider
      end

      it 'raises error' do
        expect { subject }.to raise_error(/Unknown capital_assessment_result/)
      end
    end

    context 'enable_employed_journey is true' do
      let(:before_tasks) do
        Setting.setting.update!(enable_employed_journey: true)
        allow_any_instance_of(Provider).to receive(:employment_permissions?).and_return(true)
        login_provider
        subject
      end

      context 'applicant has employment(s)' do
        let(:cfe_result) { create :cfe_v4_result, :with_employments }
        let(:td) { "\n  </th>\n  <td class=\"govuk-table__cell govuk-table__cell--numeric\">\n    " }
        let(:monthly_income_before_tax) { I18n.t('providers.capital_income_assessment_results.employment_income.monthly_income_before_tax') }
        let(:benefits_in_kind) { I18n.t('providers.capital_income_assessment_results.employment_income.benefits_in_kind') }
        let(:tax) { I18n.t('providers.capital_income_assessment_results.employment_income.tax') }
        let(:national_insurance) { I18n.t('providers.capital_income_assessment_results.employment_income.national_insurance') }
        let(:fixed_employment_deduction) { I18n.t('providers.capital_income_assessment_results.employment_income.fixed_employment_deduction') }
        let(:total) { I18n.t('providers.capital_income_assessment_results.employment_income.total') }

        it 'displays the employment income' do
          expect(unescaped_response_body).to include(I18n.t('providers.capital_income_assessment_results.other_income.title'))
          expect(unescaped_response_body).to include(I18n.t('providers.capital_income_assessment_results.employment_income.title'))
          expect(unescaped_response_body).to include(monthly_income_before_tax + td + gds_number_to_currency(cfe_result.employment_income_gross_income))
          expect(unescaped_response_body).to include(benefits_in_kind + td + gds_number_to_currency(cfe_result.employment_income_benefits_in_kind))
          expect(unescaped_response_body).to include(tax + td + gds_number_to_currency(cfe_result.employment_income_tax))
          expect(unescaped_response_body).to include(national_insurance + td + gds_number_to_currency(cfe_result.employment_income_national_insurance))
          expect(unescaped_response_body).to include(fixed_employment_deduction + td + gds_number_to_currency(cfe_result.employment_income_fixed_employment_deduction))
          expect(unescaped_response_body).to include(total + td + gds_number_to_currency(cfe_result.employment_income_net_employment_income))
        end
      end

      context 'applicant has no employment(s)' do
        let(:cfe_result) { create :cfe_v4_result, :with_no_employments }
        it 'does not display employment income' do
          expect(unescaped_response_body).not_to include(I18n.t('providers.capital_income_assessment_results.employment_income.title'))
          expect(unescaped_response_body).to include(I18n.t('providers.capital_income_assessment_results.other_income.income'))
        end
      end
    end

    context 'enable_employed_journey is false' do
      let(:before_tasks) do
        Setting.setting.update!(enable_employed_journey: false)
        allow_any_instance_of(Provider).to receive(:employment_permissions?).and_return(false)
        login_provider
        subject
      end

      context 'applicant has employment(s)' do
        let(:cfe_result) { create :cfe_v4_result, :with_employments }
        it 'does not display employment income' do
          expect(unescaped_response_body).not_to include(I18n.t('providers.capital_income_assessment_results.employment_income.title'))
          expect(unescaped_response_body).to include(I18n.t('providers.capital_income_assessment_results.other_income.income'))
        end
      end

      context 'applicant has no employment(s)' do
        let(:cfe_result) { create :cfe_v4_result, :with_employments }
        it 'does not display employment income' do
          expect(unescaped_response_body).not_to include(I18n.t('providers.capital_income_assessment_results.employment_income.title'))
          expect(unescaped_response_body).to include(I18n.t('providers.capital_income_assessment_results.other_income.income'))
        end
      end
    end
  end

  describe 'PATCH /providers/applications/:id/capital_income_assessment_result' do
    subject { patch providers_legal_aid_application_capital_income_assessment_result_path(legal_aid_application), params: params.merge(submit_button) }
    let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
    let(:params) { {} }

    context 'when the provider is authenticated' do
      before do
        login_provider
        subject
      end

      context 'Continue button pressed' do
        let(:submit_button) { { continue_button: 'Continue' } }

        it 'redirects to the merits task list' do
          expect(subject).to redirect_to(providers_legal_aid_application_merits_task_list_path)
        end
      end

      context 'Save as draft button pressed' do
        let(:submit_button) { { draft_button: 'Save as draft' } }

        it "redirects provider to provider's applications page" do
          subject
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end

        it 'sets the application as draft' do
          expect(legal_aid_application.reload).to be_draft
        end
      end
    end
  end
end
