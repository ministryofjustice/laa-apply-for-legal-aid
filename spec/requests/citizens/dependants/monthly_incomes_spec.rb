require 'rails_helper'

RSpec.describe Citizens::Dependants::MonthlyIncomesController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
  let(:dependant) { create :dependant, legal_aid_application: legal_aid_application }

  before do
    get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
    subject
  end

  describe 'GET /citizens/dependants/:id/monthly_income' do
    subject { get citizens_dependant_monthly_income_path(dependant) }

    it 'returns http status success' do
      expect(response).to have_http_status(:ok)
    end

    it "contains dependant's name" do
      subject
      expect(unescaped_response_body).to include(dependant.name)
    end
  end

  describe 'PATCH /citizens/dependants/:id/monthly_income' do
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

    subject { patch citizens_dependant_monthly_income_path(dependant), params: params }

    it 'updates the dependant' do
      dependant.reload
      expect(dependant.has_income).to eq(has_income)
      expect(dependant.monthly_income).to eq(monthly_income)
    end

    it 'redirects to the assets page' do
      expect(response).to redirect_to(citizens_dependant_assets_value_path(dependant))
    end

    context 'invalid params' do
      context 'params are missing' do
        let(:has_income) { '' }
        let(:monthly_income) { '' }

        it 'shows errors' do
          expect(unescaped_response_body).to include(I18n.t('activemodel.errors.models.dependant.attributes.has_income.blank_message', name: dependant.name))
          expect(response.body).to include(I18n.t('activemodel.errors.models.dependant.attributes.monthly_income.blank'))
        end

        it 'does not update the dependant' do
          dependant.reload
          expect(dependant.has_income).to be_nil
          expect(dependant.monthly_income).to be_nil
        end
      end
      context 'invalid values' do
        let(:has_income) { true }
        let(:monthly_income) { '0' }

        it 'shows error' do
          expect(response.body).to include(I18n.t('activemodel.errors.models.dependant.attributes.monthly_income.greater_than'))
        end
      end
    end
  end
end
