require 'rails_helper'

RSpec.describe Providers::Dependants::RelationshipsController, type: :request do
  let(:date_of_birth) { Faker::Date.birthday(min_age: 7, max_age: 77) }
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :with_transaction_period }
  let(:dependant) { create :dependant, legal_aid_application: legal_aid_application, date_of_birth: date_of_birth, relationship: nil }
  let(:provider) { legal_aid_application.provider }

  before do
    login_as provider
    subject
  end

  describe 'GET /citizens/dependants/:id/relationship' do
    subject { get citizens_dependant_relationship_path(dependant) }

    it 'returns http success' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it "contains dependant's name" do
      subject
      expect(unescaped_response_body).to include(dependant.name)
    end
  end

  describe 'PATCH /citizens/dependants/:id/relationship' do
    let(:relationship) { Dependant.relationships.keys.sample }
    let(:params) do
      {
        dependant: { relationship: relationship }
      }
    end

    subject { patch citizens_dependant_relationship_path(dependant), params: params }

    it 'updates dependant' do
      expect { subject }.to change { dependant.reload.relationship }.to(relationship)
    end

    context 'adult_relative' do
      let(:relationship) { 'adult_relative' }

      it 'redirects to dependant income' do
        subject
        expect(response).to redirect_to(citizens_dependant_monthly_income_path(dependant))
      end
    end

    context 'child_relative' do
      let(:relationship) { 'child_relative' }

      context 'dependant is less than 18' do
        let(:date_of_birth) { legal_aid_application.calculation_date - 17.years }

        it 'redirects to dependant income' do
          subject
          expect(response).to redirect_to(citizens_dependant_monthly_income_path(dependant))
        end
      end

      context 'dependant is more than 18' do
        let(:date_of_birth) { legal_aid_application.calculation_date - 20.years }

        it 'redirects to dependant income' do
          subject
          expect(response).to redirect_to(citizens_dependant_full_time_education_path(dependant))
        end
      end
    end

    context 'without value' do
      let(:params) { {} }

      it 'renders successfully' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'displays error' do
        subject
        expect(response.body).to include('govuk-error-summary')
        expect(unescaped_response_body).to include(I18n.t('activemodel.errors.models.dependant.attributes.relationship.blank', name: dependant.name))
      end
    end
  end
end
