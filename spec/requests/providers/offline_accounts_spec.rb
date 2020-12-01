require 'rails_helper'

RSpec.describe 'providers offine accounts', type: :request do
  let(:application) { create :legal_aid_application, :with_applicant, :with_savings_amount }
  let(:savings_amount) { application.savings_amount }

  describe 'GET /providers/applications/:legal_aid_application_id/offline_account' do
    subject { get providers_legal_aid_application_offline_account_path(application) }

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
    let(:offline_current_accounts) { rand(1...1_000_000.0).round(2).to_s }
    let(:check_box_offline_current_accounts) { 'true' }
    let(:params) do
      {
        savings_amount: {
          offline_current_accounts: offline_current_accounts,
          check_box_offline_current_accounts: check_box_offline_current_accounts
        }
      }
    end

    subject { patch providers_legal_aid_application_offline_account_path(application), params: params.merge(submit_button) }

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
          it 'updates the offline_current_accounts amount' do
            expect { subject }.to change { savings_amount.reload.offline_current_accounts.to_s }.to(offline_current_accounts)
          end

          it 'does not displays an error' do
            subject
            expect(response.body).not_to match('govuk-error-message')
            expect(response.body).not_to match('govuk-form-group--error')
          end

          it 'redirects to the next step in Citizen jouney' do
            subject
            expect(response).to redirect_to(providers_legal_aid_application_savings_and_investment_path(application))
          end

          context 'none of these checkbox is selected' do
            let(:params) { { savings_amount: { no_account_selected: 'true' } } }

            it 'sets no_account_selected to true' do
              subject
              expect(savings_amount.reload.no_account_selected).to eq(true)
            end
          end

          context 'with invalid input' do
            let(:offline_current_accounts) { 'fifty' }

            it 'renders successfully' do
              subject
              expect(response).to have_http_status(:ok)
            end

            it 'displays an error' do
              subject
              expect(response.body).to match(I18n.t('activemodel.errors.models.savings_amount.attributes.offline_current_accounts.not_a_number'))
              expect(response.body).to match('govuk-error-message')
              expect(response.body).to match('govuk-form-group--error')
            end
          end
        end

        context 'when in checking citizen answers state' do
          let(:state) { :checking_citizen_answers }
          let(:application) { create :legal_aid_application, :with_applicant, :with_savings_amount, :with_non_passported_state_machine, state }
          let(:submit_button) do
            {
              continue_button: 'Continue'
            }
          end
          before { subject }

          it 'redirects to the check passported answers page' do
            expect(response).to redirect_to(providers_legal_aid_application_check_passported_answers_path(application))
          end

          context 'no savings' do
            let(:offline_current_accounts) { 0 }
            let(:offline_savings_accounts) { 0 }

            it 'redirects to the check passported answers page' do
              expect(response).to redirect_to(providers_legal_aid_application_check_passported_answers_path(application))
            end

            context 'provider_entering_merits' do
              let(:state) { :provider_entering_merits }

              it 'redirects to the restrictions page' do
                expect(response).to redirect_to(providers_legal_aid_application_savings_and_investment_path(application))
              end
            end
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
          expect { subject }.to change { savings_amount.reload.offline_current_accounts.to_s }.to(offline_current_accounts)
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
          let(:offline_current_accounts) { 'fifty' }

          it 'renders successfully' do
            subject
            expect(response).to have_http_status(:ok)
          end

          it 'displays an error' do
            subject
            expect(response.body).to match(I18n.t('activemodel.errors.models.savings_amount.attributes.offline_current_accounts.not_a_number'))
            expect(response.body).to match('govuk-error-message')
            expect(response.body).to match('govuk-form-group--error')
          end
        end
      end
    end
  end
end
