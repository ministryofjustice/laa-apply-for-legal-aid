require 'rails_helper'

RSpec.describe Providers::Dependants::FullTimeEducationsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
  let(:dependant) { create :dependant, legal_aid_application: legal_aid_application }
  let(:provider) { legal_aid_application.provider }

  before do
    login_as provider
    subject
  end

  describe 'GET /citizens/dependants/:dependant_id/full_time_education' do
    subject { get providers_legal_aid_application_dependant_full_time_education_path(legal_aid_application, dependant) }

    it 'returns http success' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it "contains dependant's informations" do
      subject
      expect(unescaped_response_body).to include(dependant.name)
    end
  end

  describe 'PATCH /citizens/dependants/:dependant_id/full_time_education' do
    let(:in_full_time_education) { true }
    let(:dependant) do
      create :dependant, :over_18, legal_aid_application: legal_aid_application
    end

    let(:params) do
      { dependant: { in_full_time_education: in_full_time_education.to_s } }
    end

    subject do
      patch(providers_legal_aid_application_dependant_full_time_education_path(legal_aid_application, dependant), params: params)
    end

    it 'updates the dependant' do
      subject
      dependant.reload
      expect(dependant).to be_in_full_time_education
    end

    it 'redirects to the dependant income page' do
      subject
      expect(response).to redirect_to(citizens_dependant_monthly_income_path(dependant))
    end

    context 'when not in full time education' do
      let(:in_full_time_education) { false }

      it 'updates the dependant' do
        subject
        dependant.reload
        expect(dependant).not_to be_in_full_time_education
      end

      it 'redirects to the dependant income page' do
        subject
        expect(response).to redirect_to(citizens_dependant_monthly_income_path(dependant))
      end
    end

    context 'with nothing entered' do
      let(:in_full_time_education) { '' }

      it 'renders successfully' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'does not update the dependant' do
        expect { subject }.not_to change { dependant.reload.in_full_time_education }
      end

      it 'displays an error' do
        subject
        expect(unescaped_response_body).to match(I18n.t('activemodel.errors.models.dependant.attributes.in_full_time_education.blank_message', name: dependant.name))
        expect(response.body).to match('govuk-error-message')
        expect(response.body).to match('govuk-form-group--error')
      end
    end
  end
end
