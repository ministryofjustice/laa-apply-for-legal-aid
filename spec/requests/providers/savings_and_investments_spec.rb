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
        login_as create(:provider)
        subject
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
          let(:application) { create :legal_aid_application, :without_own_home }
          it 'points to the own  home page' do
            expect(response.body).to have_back_link(providers_legal_aid_application_own_home_path(application))
          end
        end

        context 'applicant owns home with shared ownership' do
          let(:application) { create :legal_aid_application, :with_own_home_mortgaged, :with_home_shared_with_partner }
          it 'points to the own  home page' do
            expect(response.body).to have_back_link(providers_legal_aid_application_percentage_home_path(application))
          end
        end

        context 'applicant owns home sole ownership' do
          let(:application) { create :legal_aid_application, :with_own_home_mortgaged, :with_home_sole_owner }
          it 'points to the own  home page' do
            expect(response.body).to have_back_link(providers_legal_aid_application_shared_ownership_path(application))
          end
        end
      end
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/savings_and_investment' do
    let(:isa) { Faker::Number.decimal }
    let(:check_box_isa) { 'true' }
    let(:params) do
      {
        savings_amount: {
          isa: isa,
          check_box_isa: check_box_isa
        }
      }
    end

    subject { patch providers_legal_aid_application_savings_and_investment_path(application), params: params.merge(submit_button) }

    context 'when the provider is authenticated' do
      before do
        login_as create(:provider)
      end

      context 'Submitted with Continue button' do
        let(:submit_button) do
          {
            continue_button: 'Continue'
          }
        end

        it 'updates the isa amount' do
          expect { subject }.to change { savings_amount.reload.isa.to_s }.to(isa)
        end

        it 'does not displays an error' do
          subject
          expect(response.body).not_to match('govuk-error-message')
          expect(response.body).not_to match('govuk-form-group--error')
        end

        xit 'redirects to the next step in Citizen jouney' do
          # TODO: - set redirect path when known
          subject
          expect(response).to redirect_to(:some_path)
        end

        it 'displays holding page' do
          subject
          expect(response).to redirect_to providers_legal_aid_application_other_assets_path(application)
        end

        context 'with invalid input' do
          let(:isa) { 'fifty' }

          it 'renders successfully' do
            subject
            expect(response).to have_http_status(:ok)
          end

          it 'displays an error' do
            subject
            expect(response.body).to match(I18n.t('activemodel.errors.models.savings_amount.attributes.isa.not_a_number'))
            expect(response.body).to match('govuk-error-message')
            expect(response.body).to match('govuk-form-group--error')
          end
        end
      end

      context 'Submitted with Save as draft button' do
        let(:submit_button) do
          {
            draft_button: 'Save as draft'
          }
        end

        it 'updates the isa amount' do
          expect { subject }.to change { savings_amount.reload.isa.to_s }.to(isa)
        end

        it 'does not displays an error' do
          subject
          expect(response.body).not_to match('govuk-error-message')
          expect(response.body).not_to match('govuk-form-group--error')
        end

        xit 'redirects to the next step in Citizen jouney' do
          # TODO: - set redirect path when known
          subject
          expect(response).to redirect_to(:some_path)
        end

        it 'displays holding page' do
          subject
          expect(response).to redirect_to providers_legal_aid_applications_path
        end

        context 'with invalid input' do
          let(:isa) { 'fifty' }

          it 'renders successfully' do
            subject
            expect(response).to have_http_status(:ok)
          end

          it 'displays an error' do
            subject
            expect(response.body).to match(I18n.t('activemodel.errors.models.savings_amount.attributes.isa.not_a_number'))
            expect(response.body).to match('govuk-error-message')
            expect(response.body).to match('govuk-form-group--error')
          end
        end
      end
    end
  end
end
