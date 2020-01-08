require 'rails_helper'

RSpec.describe Providers::Dependants::DetailsController, type: :request do
  let(:calculation_date) { Date.current }
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant, transaction_period_finish_on: calculation_date }
  let(:dependant) { create :dependant, legal_aid_application: legal_aid_application }
  let(:provider) { legal_aid_application.provider }

  before do
    login_as provider
    subject
  end

  describe 'GET /providers/:application_id/dependants/:id/details' do
    subject { get providers_legal_aid_application_applicant_details_path(legal_aid_application, dependant) }

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it "contains dependant's informations" do
      expect(unescaped_response_body).to include(dependant.name)
      expect(unescaped_response_body).to include(dependant.date_of_birth.year.to_s)
      expect(unescaped_response_body).to include(dependant.date_of_birth.month.to_s)
      expect(unescaped_response_body).to include(dependant.date_of_birth.day.to_s)
    end
  end

  describe 'PATCH /providers/:application_id/dependants/:id/details' do
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

    subject { patch providers_legal_aid_application_applicant_details_path(legal_aid_application, dependant), params: params }

    it 'updates the dependant' do
      dependant.reload
      expect(dependant.name).to eq(param_name)
      expect(dependant.date_of_birth).to eq(param_date_of_birth.to_date)
    end

    it 'redirects to the dependant relationship page if the dependant is more than 15 years old' do
      expect(response).to redirect_to(citizens_dependant_relationship_path(dependant))
    end

    context 'dependant is less than 15 years old' do
      let(:param_date_of_birth) { calculation_date - 10.years }

      it 'redirects to the page asking if you have other dependant' do
        expect(response).to redirect_to(citizens_has_other_dependant_path)
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
  end
end
