require 'rails_helper'

RSpec.describe 'check benefits requests', type: :request do
  let(:last_name) { 'WALKER' }
  let(:date_of_birth) { '1980/01/10'.to_date }
  let(:national_insurance_number) { 'JA293483A' }
  let(:applicant) { create :applicant, last_name: last_name, date_of_birth: date_of_birth, national_insurance_number: national_insurance_number }
  let(:application) { create :application, applicant: applicant, state: 'checking_applicant_details' }
  let(:address_lookup_used) { true }
  let(:login) { login_as application.provider }
  let(:login) { login_as application.provider }
  let(:env_allow_non_passported_route) { [true, false].sample }
  let(:setting_allow_non_passported_route) { [true, false].sample }

  before do
    Setting.create!(allow_non_passported_route: setting_allow_non_passported_route)
    allow(Rails.configuration.x).to receive(:allow_non_passported_route).and_return(env_allow_non_passported_route)
  end

  describe 'GET /providers/applications/:application_id/check_benefits', :vcr do
    let!(:address) { create :address, applicant: applicant, lookup_used: address_lookup_used }
    subject { get "/providers/applications/#{application.id}/check_benefits" }

    before { login }

    it 'returns http success' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'generates a new check_benefit_result' do
      expect { subject }.to change { BenefitCheckResult.count }.by(1)
    end

    it 'has not transitioned the state' do
      subject
      expect(application.reload.state).to eq 'applicant_details_checked'
    end

    context 'when the check_benefit_result already exists' do
      let!(:benefit_check_result) { create :benefit_check_result, legal_aid_application: application }

      it 'does not generate a new one' do
        expect(BenefitCheckService).not_to receive(:call)
        expect { subject }.to_not change { BenefitCheckResult.count }
      end

      context 'and the applicant has since been modified' do
        before { applicant.update(first_name: Faker::Name.first_name) }
        let!(:benefit_check_result) { travel(-10.minutes) { create :benefit_check_result, legal_aid_application: application } }

        it 'updates check_benefit_result' do
          expect(BenefitCheckService).to receive(:call).and_call_original
          subject
        end
      end
    end

    context 'when the applicant receives benefits' do
      let!(:benefit_check_result) { create :benefit_check_result, :positive, legal_aid_application: application }

      it 'show positive result text' do
        subject
        text = I18n.t('providers.check_benefits.check_benefits_result.positive_result.title', name: applicant.full_name)
        expect(response.body).to include(text)
      end
    end

    context 'when the applicant does not receive benefits' do
      let!(:benefit_check_result) { create :benefit_check_result, :negative, legal_aid_application: application }

      context 'when environment is not allowed to go through non-passported route' do
        let(:env_allow_non_passported_route) { false }

        it 'shows text to use CCMS' do
          subject
          expect(response.body).to include(I18n.t('providers.check_benefits.use_ccms.title', name: applicant.full_name))
        end

        it 'sets the application to use_ccms state' do
          subject
          expect(application.reload.state).to eq 'use_ccms'
        end
      end

      context 'when environment is allowed to go through non-passported route' do
        let(:env_allow_non_passported_route) { true }

        context 'when setting have allow_non_passported_route false' do
          let(:setting_allow_non_passported_route) { false }

          it 'shows text to use CCMS' do
            subject
            expect(response.body).to include(I18n.t('providers.check_benefits.use_ccms.title'))
          end

          it 'transitions the application to use_ccms' do
            subject
            expect(application.reload.state).to eq 'use_ccms'
          end
        end

        context 'when setting have allow_non_passported_route true' do
          let(:setting_allow_non_passported_route) { true }

          it 'show negative result text' do
            subject
            expect(unescaped_response_body).to include I18n.t('providers.check_benefits.check_benefits_result.negative_result.title')
          end
        end
      end
    end

    context 'with known issue' do
      let(:last_name) { 'O' }

      it 'set benefit check result as known' do
        subject
        expect(application.reload.benefit_check_result&.result).to eq('skipped:known_issue')
      end

      it 'redirects to next step' do
        subject
        expect(response).to redirect_to(flow_forward_path)
      end
    end

    context 'the benefit check service is down' do
      before { allow(BenefitCheckService).to receive(:call).and_return(false) }

      it 'redirects to the Problem page' do
        subject
        expect(response).to redirect_to(problem_index_path)
      end
    end

    context 'when the provider is not authenticated' do
      let(:login) { nil }
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end
  end

  describe 'PATCH /providers/applications/:application_id/check_benefit' do
    before { patch providers_legal_aid_application_check_benefit_path(application.id), params: params }

    subject { patch providers_legal_aid_application_check_benefit_path(application.id), params: params }

    before do
      login
      subject
    end

    context 'Form submitted with Continue button' do
      let(:params) do
        {
          continue_button: 'Continue'
        }
      end

      context 'when the check_benefit_results is positive' do
        let(:application) { create :legal_aid_application, :with_positive_benefit_check_result }

        it 'displays the capital introduction page' do
          expect(response).to redirect_to providers_legal_aid_application_capital_introduction_path(application)
        end
      end

      context 'when the check benefit result is negative' do
        let(:application) { create :legal_aid_application, :with_negative_benefit_check_result }

        it 'displays the online banking page' do
          expect(response).to redirect_to providers_legal_aid_application_open_banking_consents_path(application)
        end
      end

      context 'when the check benefit result is undetermined' do
        let(:application) { create :legal_aid_application, :with_undetermined_benefit_check_result }

        it 'displays the online banking page' do
          expect(response).to redirect_to providers_legal_aid_application_open_banking_consents_path(application)
        end
      end

      context 'when delegated functions used' do
        let(:application) { create :legal_aid_application, :with_positive_benefit_check_result, used_delegated_functions: true }

        it 'displays the substantive application page' do
          expect(response).to redirect_to providers_legal_aid_application_substantive_application_path(application)
        end
      end
    end

    context 'Form submitted with Save as draft button' do
      let(:params) do
        {
          draft_button: 'Save as draft'
        }
      end

      context 'when the check_benefit_results is positive' do
        let(:application) { create :legal_aid_application, :with_positive_benefit_check_result }

        it 'displays the providers applications page' do
          expect(response).to redirect_to providers_legal_aid_applications_path
        end

        it 'sets the application as draft' do
          expect(application.reload).to be_draft
        end
      end

      context 'when the check benefit result is negative' do
        let(:application) { create :legal_aid_application, :with_negative_benefit_check_result }

        it 'displays providers applications page' do
          expect(response).to redirect_to providers_legal_aid_applications_path
        end
      end

      context 'when the check benefit result is undetermined' do
        let(:application) { create :legal_aid_application, :with_undetermined_benefit_check_result }

        it 'displays providers applications page' do
          expect(response).to redirect_to providers_legal_aid_applications_path
        end
      end
    end
  end
end
