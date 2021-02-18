require 'rails_helper'

RSpec.describe Providers::ApplicantsController, type: :request do
  let(:office) { create :office }
  let(:provider) { create :provider, selected_office: office }
  let(:login) { login_as provider }

  before { login }

  describe 'GET /providers/applicants/new' do
    subject { get new_providers_applicant_path }

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'does not prefix page title with error label' do
      subject
      expect(response.body).not_to match(/<title>#{I18n.t('errors.title_prefix')}:/)
    end
  end

  describe 'POST /providers/applicants' do
    let(:submit_button) { {} }
    let(:param_applicant) { FactoryBot.attributes_for :applicant }
    let(:params) do
      {
        applicant: param_applicant.merge(
          'date_of_birth(1i)': param_applicant[:date_of_birth].year.to_s,
          'date_of_birth(2i)': param_applicant[:date_of_birth].month.to_s,
          'date_of_birth(3i)': param_applicant[:date_of_birth].day.to_s
        ).except(:date_of_birth)
      }
    end
    let(:legal_aid_application) { provider.legal_aid_applications.last }
    let(:applicant) { legal_aid_application.applicant }
    let(:next_url) { providers_legal_aid_application_address_lookup_path(legal_aid_application) }

    subject { post providers_applicants_path, params: params.merge(submit_button) }

    it "creates an application with the provider's office" do
      expect { subject }.to change { provider.legal_aid_applications.count }.by(1)
      expect(legal_aid_application.office.id).to eq(provider.selected_office.id)
    end

    it 'creates an applicant' do
      expect { subject }.to change { Applicant.count }.by(1)
      expect(applicant).to be_present
      expect(applicant.first_name).to eq(param_applicant[:first_name])
      expect(applicant.last_name).to eq(param_applicant[:last_name])
      expect(applicant.national_insurance_number).to eq(param_applicant[:national_insurance_number])
      expect(applicant.date_of_birth).to eq(param_applicant[:date_of_birth])
    end

    it 'redirects to next page' do
      subject
      expect(response).to redirect_to(next_url)
    end

    it "back link on the next page is to applicant's details page" do
      get new_providers_applicant_path
      subject
      follow_redirect!
      expect(response.body).to have_back_link(providers_legal_aid_application_applicant_details_path(legal_aid_application, back: true))
    end

    context 'with missing parameters' do
      let(:params) { { applicant: { first_name: 'bob' } } }

      it 'displays errors' do
        subject
        expect(response.body).to include('govuk-error-summary')
      end

      it 'prefixes page title with error label' do
        subject
        expect(response.body).to match(/<title>#{I18n.t('errors.title_prefix')}:/)
      end

      it 'does not create applicant' do
        expect { subject }.not_to change { Applicant.count }
      end

      it 'does not create application' do
        expect { subject }.not_to change { LegalAidApplication.count }
      end
    end

    context 'Form submitted using Save as draft button' do
      let(:submit_button) { { draft_button: 'Save as draft' } }

      it "redirects provider to provider's applications page" do
        subject
        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end

      it 'creates an application as draft' do
        expect { subject }.to change { provider.legal_aid_applications.count }.by(1)
        expect(legal_aid_application.draft?).to eq(true)
      end

      it 'creates an applicant' do
        expect { subject }.to change { Applicant.count }.by(1)
        expect(applicant).to be_present
        expect(applicant.first_name).to eq(param_applicant[:first_name])
        expect(applicant.last_name).to eq(param_applicant[:last_name])
        expect(applicant.national_insurance_number).to eq(param_applicant[:national_insurance_number])
        expect(applicant.date_of_birth).to eq(param_applicant[:date_of_birth])
      end

      context 'with blank entries' do
        let(:params) { { applicant: { first_name: 'bob' } } }

        it "redirects provider to provider's applications page" do
          subject
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end

        it 'sets the application as draft' do
          subject
          expect(legal_aid_application.draft?).to eq(true)
        end

        it 'leaves values blank' do
          subject
          expect(applicant.last_name).to be_blank
          expect(applicant.national_insurance_number).to be_blank
        end
      end
    end

    context 'when the provider is not authenticated' do
      let(:login) { nil }
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end
  end
end
