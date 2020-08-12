require 'rails_helper'

RSpec.describe 'providers savings and investments', type: :request do
  let(:application) { create :legal_aid_application, :with_applicant, :with_savings_amount }
  let(:savings_amount) { application.savings_amount }

  describe 'GET /providers/applications/:legal_aid_application_id/savings_and_investment' do
    subject { get providers_legal_aid_application_savings_and_investment_path(application) }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        login_as application.provider
      end

      it 'returns http success' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'does not show bank account details' do
        subject
        expect(response.body).not_to match('Account number')
      end

      describe 'back link' do
        context 'applicant does not own home' do
          before { get providers_legal_aid_application_own_home_path(application) }

          it 'points to the own  home page' do
            subject
            expect(response.body).to have_back_link(providers_legal_aid_application_own_home_path(application, back: true))
          end
        end

        context 'applicant owns home with shared ownership' do
          before { get providers_legal_aid_application_percentage_home_path(application) }

          it 'points to percentage owned page' do
            subject
            expect(response.body).to have_back_link(providers_legal_aid_application_percentage_home_path(application, back: true))
          end
        end

        context 'applicant owns home sole ownership' do
          before { get providers_legal_aid_application_shared_ownership_path(application) }

          it 'points to the shared ownership page' do
            subject
            expect(response.body).to have_back_link(providers_legal_aid_application_shared_ownership_path(application, back: true))
          end
        end
      end
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/savings_and_investment' do
    let(:cash) { rand(1...1_000_000.0).round(2).to_s }
    let(:check_box_cash) { 'true' }
    let(:params) do
      {
        savings_amount: {
          cash: cash,
          check_box_cash: check_box_cash
        }
      }
    end

    subject { patch providers_legal_aid_application_savings_and_investment_path(application), params: params.merge(submit_button) }

    context 'when the provider is authenticated' do
      before do
        login_as application.provider
      end

      context 'Submitted with Continue button' do
        let(:submit_button) do
          {
            continue_button: 'Continue'
          }
        end

        context 'not in checking passported answers state' do
          it 'updates the cash amount' do
            expect { subject }.to change { savings_amount.reload.cash.to_s }.to(cash)
          end

          it 'does not displays an error' do
            subject
            expect(response.body).not_to match('govuk-error-message')
            expect(response.body).not_to match('govuk-form-group--error')
          end

          it 'redirects to the next step in Citizen jouney' do
            subject
            expect(response).to redirect_to(providers_legal_aid_application_other_assets_path(application))
          end

          context 'none of these checkbox is selected' do
            let(:params) { { savings_amount: { none_selected: 'true' } } }

            it 'sets none_selected to true' do
              subject
              expect(savings_amount.reload.none_selected).to eq(true)
            end
          end

          context 'with invalid input' do
            let(:cash) { 'fifty' }

            it 'renders successfully' do
              subject
              expect(response).to have_http_status(:ok)
            end

            it 'displays an error' do
              subject
              expect(response.body).to match(I18n.t('activemodel.errors.models.savings_amount.attributes.cash.not_a_number'))
              expect(response.body).to match('govuk-error-message')
              expect(response.body).to match('govuk-form-group--error')
            end
          end

          context 'checkbox checked with no value entered' do
            let(:params) do
              {
                savings_amount: {
                  cash: '',
                  check_box_cash: 'true'
                }
              }
            end

            it 'displays error for field' do
              subject
              expect(response.body).to match(I18n.t('activemodel.errors.models.savings_amount.attributes.cash.blank'))
            end
          end
        end

        context 'when in checking passported answers state' do
          let(:application) { create :legal_aid_application, :with_applicant, :with_savings_amount, :with_passported_state_machine, :checking_passported_answers }
          let(:submit_button) do
            {
              continue_button: 'Continue'
            }
          end
          before { subject }

          it 'redirects to the restrictions page' do
            expect(response).to redirect_to(providers_legal_aid_application_restrictions_path(application))
          end

          context 'no savings' do
            let(:offline_current_accounts) { 0 }
            let(:offline_savings_accounts) { 0 }

            it 'redirects to the restrictions page' do
              expect(response).to redirect_to(providers_legal_aid_application_restrictions_path(application))
            end
          end
        end

        context "provider checking citizen's answers" do
          let(:application) { create :legal_aid_application, :with_applicant, :with_savings_amount, :with_non_passported_state_machine, :checking_non_passported_means }
          let(:submit_button) do
            {
              continue_button: 'Continue'
            }
          end
          before { subject }

          it 'redirects to the restrictions page' do
            expect(response).to redirect_to(providers_legal_aid_application_restrictions_path(application))
          end
        end
      end

      context 'Submitted with Save as draft button' do
        let(:submit_button) do
          {
            draft_button: 'Save as draft'
          }
        end

        it 'updates the offline_current_accounts amount' do
          expect { subject }.to change { savings_amount.reload.cash.to_s }.to(cash)
        end

        it 'does not displays an error' do
          subject
          expect(response.body).not_to match('govuk-error-message')
          expect(response.body).not_to match('govuk-form-group--error')
        end

        it 'redirects to the next step in Citizen jouney' do
          subject
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end

        it 'displays holding page' do
          subject
          expect(response).to redirect_to providers_legal_aid_applications_path
        end

        context 'with invalid input' do
          let(:cash) { 'fifty' }

          it 'renders successfully' do
            subject
            expect(response).to have_http_status(:ok)
          end

          it 'displays an error' do
            subject
            expect(response.body).to match(I18n.t('activemodel.errors.models.savings_amount.attributes.cash.not_a_number'))
            expect(response.body).to match('govuk-error-message')
            expect(response.body).to match('govuk-form-group--error')
          end
        end
      end
    end
  end
end
