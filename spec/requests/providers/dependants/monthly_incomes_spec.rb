require 'rails_helper'

RSpec.describe Providers::Dependants::MonthlyIncomesController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :with_transaction_period }
  let(:dependant) { create :dependant, :over_18, in_full_time_education: false, legal_aid_application: legal_aid_application }
  let(:provider) { legal_aid_application.provider }

  before do
    login_as provider
    subject
  end

  describe 'GET /providers/:legal_aid_application_id/dependants/:id/monthly_income' do
    subject { get providers_legal_aid_application_dependant_monthly_income_path(legal_aid_application, dependant) }

    it 'returns http status success' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it "contains dependant's name" do
      subject
      expect(unescaped_response_body).to include(dependant.name)
    end
  end

  describe 'PATCH /providers/:legal_aid_application_id/dependants/:id/monthly_income' do
    let(:has_income) { true }
    let(:monthly_income) { 1234 }
    let(:params) do
      {
        dependant: {
          has_income: has_income,
          monthly_income: monthly_income
        }
      }
    end

    subject { patch providers_legal_aid_application_dependant_monthly_income_path(legal_aid_application, dependant), params: params }

    it 'updates the dependant' do
      subject
      dependant.reload
      expect(dependant.has_income).to eq(has_income)
      expect(dependant.monthly_income).to eq(monthly_income)
    end

    it 'redirects to the assets page' do
      subject
      expect(response).to redirect_to(providers_legal_aid_application_dependant_assets_value_path(legal_aid_application, dependant))
    end

    context 'dependant is less than 18' do
      let(:dependant) { create :dependant, :under_18, legal_aid_application: legal_aid_application }

      it 'redirects to the assets page' do
        subject
        expect(response).to redirect_to(providers_legal_aid_application_has_other_dependant_path(legal_aid_application))
      end
    end

    context 'dependant is full time education' do
      let(:dependant) { create :dependant, :over_18, in_full_time_education: true, legal_aid_application: legal_aid_application }

      it 'redirects to the assets page' do
        subject
        expect(response).to redirect_to(providers_legal_aid_application_has_other_dependant_path(legal_aid_application))
      end
    end

    context 'invalid params' do
      context 'params are missing' do
        let(:has_income) { '' }
        let(:monthly_income) { '' }

        it 'shows errors' do
          subject
          expect(unescaped_response_body).to include(I18n.t('activemodel.errors.models.dependant.attributes.has_income.blank_message', name: dependant.name))
          expect(response.body).to include(I18n.t('activemodel.errors.models.dependant.attributes.monthly_income.blank'))
        end

        it 'does not update dependant.has_income' do
          expect { subject }.not_to change { dependant.reload.has_income }
        end

        it 'does not update dependant.monthly_income' do
          expect { subject }.not_to change { dependant.reload.monthly_income }
        end
      end

      context 'invalid values' do
        let(:has_income) { true }
        let(:monthly_income) { '0' }

        it 'shows error' do
          subject
          expect(response.body).to include(I18n.t('activemodel.errors.models.dependant.attributes.monthly_income.greater_than'))
        end
      end
    end
  end
end
