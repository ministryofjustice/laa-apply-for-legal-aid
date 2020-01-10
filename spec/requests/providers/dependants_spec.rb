require 'rails_helper'

RSpec.describe Providers::DependantsController, type: :request do
  let(:calculation_date) { Date.current }
  let!(:legal_aid_application) { create :legal_aid_application, :with_applicant, transaction_period_finish_on: calculation_date }
  let(:dependant) { legal_aid_application.dependants.last }
  let(:provider) { legal_aid_application.provider }
  let(:skip_subject) { false }
  before do
    login_as provider
    subject unless skip_subject
  end

  describe 'GET /providers/:application_id/dependant_details/:id' do
    subject { get providers_legal_aid_application_dependants_path(legal_aid_application) }

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /providers/:application_id/dependants' do
    let(:param_name) { Faker::Name.name }
    let(:param_date_of_birth) { calculation_date - 20.years }
    let(:params) do
      {
        dependant: {
          name: param_name,
          dob_year: param_date_of_birth.year.to_s,
          dob_month: param_date_of_birth.month.to_s,
          dob_day: param_date_of_birth.day.to_s
        }
      }
    end
    let(:latest_dependant) { Dependant.order(:created_at).last }

    subject { post providers_legal_aid_application_dependants_path(legal_aid_application), params: params }

    context 'reloading ' do
      let(:skip_subject) { true }

      it 'creates the dependant' do
        expect { subject }.to change { legal_aid_application.reload.dependants.count }.by(1)
        expect(dependant.name).to eq(param_name)
        expect(dependant.date_of_birth).to eq(param_date_of_birth.to_date)
      end
    end

    it 'redirects to the dependant relationship page if the dependant is more than 15 years old' do
      binding.pry
      expect(response).to redirect_to(providers_legal_aid_application_dependant_relationship_path(legal_aid_application, dependant_id: latest_dependant.id))
    end

    context 'dependant is less than 15 years old' do
      let(:param_date_of_birth) { calculation_date - 10.years }

      it 'redirects to the page asking if you have other dependant' do
        expect(response).to redirect_to(providers_legal_aid_application_has_other_dependant_path(legal_aid_application))
      end
    end

    context 'when the params are missing' do
      let(:params) do
        {
          dependant: {
            name: '',
            dob_year: ''
          }
        }
      end

      it 'show errors' do
        expect(response.body).to include(I18n.t('activemodel.errors.models.dependant.attributes.name.blank'))
        expect(response.body).to include(I18n.t('activemodel.errors.models.dependant.attributes.date_of_birth.blank'))
      end
    end

    context 'when the date of birth is in the future' do
      let(:param_date_of_birth) { Time.now + 2.years }

      it 'show errors' do
        expect(response.body).to include(I18n.t('activemodel.errors.models.dependant.attributes.date_of_birth.date_is_in_the_future'))
      end
    end

    context 'when the date of birth is too long ago' do
      let(:param_date_of_birth) { Time.now - 1000.years }

      it 'show errors' do
        expect(response.body).to include(I18n.t('activemodel.errors.models.dependant.attributes.date_of_birth.earliest_allowed_date', date: '01 01 1900'))
      end
    end

    context 'when the date has wrong format' do
      let(:params) do
        {
          dependant: {
            name: param_name,
            dob_year: param_date_of_birth.year.to_s,
            dob_month: '24',
            dob_day: param_date_of_birth.day.to_s
          }
        }
      end

      it 'show errors' do
        expect(response.body).to include(I18n.t('activemodel.errors.models.dependant.attributes.date_of_birth.date_not_valid'))
      end
    end

    context 'when the date contains alphabetic characters' do
      let(:params) do
        {
          dependant: {
            name: param_name,
            dob_year: param_date_of_birth.year.to_s,
            dob_month: '2s',
            dob_day: param_date_of_birth.day.to_s
          }
        }
      end

      it 'show errors' do
        expect(response.body).to include(I18n.t('activemodel.errors.models.dependant.attributes.date_of_birth.date_not_valid'))
      end
    end
  end
end
