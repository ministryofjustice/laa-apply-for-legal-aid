require 'rails_helper'

RSpec.describe Providers::MeansSummariesController, type: :request do
  include ActionView::Helpers::NumberHelper
  let(:provider) { create :provider }
  let(:applicant) { create :applicant }
  let(:transaction_type) { create :transaction_type }
  let(:bank_provider) { create :bank_provider, applicant: applicant }
  let(:bank_account) { create :bank_account, bank_provider: bank_provider }
  let(:vehicle) { create :vehicle, :populated }
  let(:own_vehicle) { true }
  let(:legal_aid_application) do
    create :legal_aid_application,
           :with_negative_benefit_check_result,
           vehicle: vehicle,
           own_vehicle: own_vehicle,
           applicant: applicant,
           provider: provider,
           transaction_types: [transaction_type],
           state: :provider_assessing_means
  end
  let(:login) { login_as provider }

  describe 'GET /providers/applications/:legal_aid_application_id/means_summary' do
    let!(:bank_transactions) { create_list :bank_transaction, 3, transaction_type: transaction_type, bank_account: bank_account }

    subject { get providers_legal_aid_application_means_summary_path(legal_aid_application) }

    before do
      login
      subject
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'displays the bank transaction data' do
      total_amount = bank_transactions.sum(&:amount)
      expect(total_amount).not_to be_zero
      expect(response.body).to include(ActiveSupport::NumberHelper.number_to_currency(total_amount))
    end

    it 'displays the correct vehicles details' do
      expect(response.body).to include(number_to_currency(vehicle.estimated_value, unit: '£'))
      expect(response.body).to include(number_to_currency(vehicle.payment_remaining, unit: '£'))
      expect(response.body).to include(yes_no(vehicle.more_than_three_years_old?))
      expect(response.body).to include(I18n.t('shared.check_answers.vehicles.providers.heading'))
      expect(response.body).to include(I18n.t('shared.check_answers.vehicles.providers.own'))
      expect(response.body).to include(I18n.t('shared.check_answers.vehicles.providers.estimated_value'))
      expect(response.body).to include(I18n.t('shared.check_answers.vehicles.providers.payment_remaining'))
      expect(response.body).to include(I18n.t('shared.check_answers.vehicles.providers.more_than_three_years_old'))
      expect(response.body).to include(I18n.t('shared.check_answers.vehicles.providers.used_regularly'))
    end

    context 'when not logged in' do
      let(:login) {}
      it_behaves_like 'a provider not authenticated'
    end

    context 'applicant does not have vehicle' do
      let(:vehicle) { nil }
      let(:own_vehicle) { false }
      it 'displays first vehicle question' do
        expect(response.body).to include(I18n.t('shared.check_answers.vehicles.providers.own'))
      end

      it 'does not display other vehicle questions' do
        expect(response.body).not_to include(I18n.t('shared.check_answers_vehicles.providers.estimated_value'))
        expect(response.body).not_to include(I18n.t('shared.check_answers_vehicles.providers.payment_remaining'))
        expect(response.body).not_to include(I18n.t('shared.check_answers_vehicles.providers.purchased_on'))
        expect(response.body).not_to include(I18n.t('shared.check_answers_vehicles.providers.used_regularly'))
      end
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/means_summary' do
    let(:params) { {} }
    subject do
      get providers_legal_aid_application_means_summary_path(legal_aid_application)
      patch providers_legal_aid_application_means_summary_path(legal_aid_application), params: params
    end

    context 'unauthenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'logged in as an authenticated provider' do
      before do
        login
        allow(CFE::SubmissionManager).to receive(:call).with(legal_aid_application.id).and_return(cfe_result)
        subject
      end

      context 'call to Check Financial Eligibility Service is successful' do
        let(:cfe_result) { true }

        it 'redirects along the successful path' do
          expect(response).to redirect_to flow_forward_path
        end

        it 'transitions to provider_checked_citizens_means_answers state' do
          expect(legal_aid_application.reload.provider_checked_citizens_means_answers?).to be true
        end

        context 'Form submitted using Save as draft button' do
          let(:params) { { draft_button: 'Save as draft' } }

          it "redirects provider to provider's applications page" do
            subject
            expect(response).to redirect_to(providers_legal_aid_applications_path)
          end

          it 'sets the application as draft' do
            expect(legal_aid_application.reload).to be_draft
          end
        end
      end

      context 'call to Check Financial Eligibility Service is unsuccessful' do
        let(:cfe_result) { false }

        it 'redirects to the problem page' do
          expect(response).to redirect_to(problem_index_path)
        end
      end
    end
  end

  def yes_no(value)
    value ? 'Yes' : 'No'
  end
end
