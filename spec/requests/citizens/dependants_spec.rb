require 'rails_helper'

RSpec.describe Citizens::DependantsController, type: :request do
  let(:submission_date) { Time.now }
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant, transaction_period_finish_at: submission_date }
  let(:dependant) { legal_aid_application.dependants.last }

  before do
    get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
  end

  describe 'GET /citizens/dependant_details/:id' do
    subject { get citizens_dependants_path }

    it 'returns http success' do
      subject
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /citizens/dependants' do
    let(:param_name) { Faker::Name.name }
    let(:param_date_of_birth) { submission_date - 20.years }
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

    subject { post citizens_dependants_path, params: params }

    it 'creates the dependant' do
      expect { subject }.to change { legal_aid_application.reload.dependants.count }.by(1)
      expect(dependant.name).to eq(param_name)
      expect(dependant.date_of_birth).to eq(param_date_of_birth.to_date)
    end

    it 'redirects to the dependant relationship page if the dependant is more than 15 years old' do
      subject
      expect(unescaped_response_body).to include "[PLACEHOLDER] - #{param_name} - dependant relationship"
    end

    context 'dependant is less than 15 years old' do
      let(:param_date_of_birth) { submission_date - 10.years }

      it 'redirects to the page asking if you have other dependant' do
        subject
        expect(response.body).to include '[PLACEHOLDER] do you have any other dependant?'
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
        subject
        expect(response.body).to include(I18n.t('activemodel.errors.models.dependant.attributes.name.blank'))
        expect(response.body).to include(I18n.t('activemodel.errors.models.dependant.attributes.date_of_birth.blank'))
      end
    end

    context 'when the date of birth is in the future' do
      let(:param_date_of_birth) { Time.now + 2.years }

      it 'show errors' do
        subject
        expect(response.body).to include(I18n.t('activemodel.errors.models.dependant.attributes.date_of_birth.date_is_in_the_future'))
      end
    end

    context 'when the date of birth is too long ago' do
      let(:param_date_of_birth) { Time.now - 1000.years }

      it 'show errors' do
        subject
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
        subject
        expect(response.body).to include(I18n.t('activemodel.errors.models.dependant.attributes.date_of_birth.date_not_valid'))
      end
    end
  end
end
