require 'rails_helper'

RSpec.describe Providers::CheckBenefitsController, type: :request do
  let(:last_name) { 'WALKER' }
  let(:date_of_birth) { '1980/01/10'.to_date }
  let(:national_insurance_number) { 'JA293483A' }
  let(:applicant) { create :applicant, last_name: last_name, date_of_birth: date_of_birth, national_insurance_number: national_insurance_number }
  let(:application) { create :application, :checking_applicant_details, applicant: applicant }
  let(:address_lookup_used) { true }
  let(:login) { login_as application.provider }
  let(:provider) { create :provider }

  describe 'GET /providers/applications/:application_id/check_benefits', :vcr do
    let!(:address) { create :address, applicant: applicant, lookup_used: address_lookup_used }
    subject { get "/providers/applications/#{application.id}/check_benefits" }

    before { login }

    it 'returns http success' do
      subject
      expect(response).to have_http_status(:ok)
    end

    context '#pre_dwp_check?' do
      it 'returns true' do
        expect(described_class.new.pre_dwp_check?).to be true
      end
    end

    it 'generates a new check_benefit_result' do
      expect { subject }.to change { BenefitCheckResult.count }.by(1)
    end

    it 'has not transitioned the state' do
      subject
      expect(application.reload.state).to eq 'applicant_details_checked'
    end

    context 'state is provider_entering_means' do
      let(:application) { create :application, :provider_entering_means, applicant: applicant }

      it 'transitions from provider_entering_means' do
        subject
        expect(application.reload.state).to eq 'applicant_details_checked'
      end
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

    context 'when dwp override is enabled' do
      before(:all) { Setting.setting.update!(override_dwp_results: true) }
      after(:all) { Setting.setting.update!(override_dwp_results: false) }

      before { subject }

      context 'when the check benefit result is positive' do
        let(:application) { create :legal_aid_application, :with_applicant, :with_positive_benefit_check_result, :at_checking_applicant_details }

        it 'displays the passported result page' do
          expect(response.body).to include 'receives benefits that qualify for legal aid'
        end
      end

      context 'when the check benefit result is negative' do
        let(:application) { create :legal_aid_application, :with_applicant, :with_negative_benefit_check_result, :at_checking_applicant_details }

        it 'displays the confirm dwp non passported_applications page' do
          expect(response).to redirect_to providers_legal_aid_application_confirm_dwp_non_passported_applications_path(application)
        end
      end
    end
  end

  describe 'PATCH /providers/applications/:application_id/check_benefit' do
    subject { patch providers_legal_aid_application_check_benefit_path(application.id), params: params }

    before do
      login
      application.reload
      application.application_proceeding_types.map(&:reload)
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

        it 'displays the open banking consent page' do
          expect(response).to redirect_to providers_legal_aid_application_applicant_employed_index_path(application)
        end
      end

      context 'when the check benefit result is undetermined' do
        let(:application) { create :legal_aid_application, :with_undetermined_benefit_check_result }

        it 'displays the open banking consent page' do
          expect(response).to redirect_to providers_legal_aid_application_applicant_employed_index_path(application)
        end
      end

      context 'when delegated functions used' do
        let!(:application) do
          create :legal_aid_application,
                 :with_positive_benefit_check_result,
                 :with_proceeding_types,
                 :with_delegated_functions
        end

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

  describe 'allowed to continue or use ccms?' do
    before { login_as provider }

    context 'application passported' do
      let(:application) { create :legal_aid_application, :with_positive_benefit_check_result, :checking_applicant_details, applicant: applicant, provider: provider }

      context 'permissions passported' do
        let(:provider) { create :provider, :with_passported_permissions }
        it 'allows us to continue' do
          get "/providers/applications/#{application.id}/check_benefits"
          expect(response.body).to include('receives benefits that qualify for legal aid')
        end
      end

      context 'no permissions' do
        let(:provider) { create :provider, :with_no_permissions }
        it 'allows us to continue' do
          get "/providers/applications/#{application.id}/check_benefits"
          expect(response.body).to include('receives benefits that qualify for legal aid')
        end
      end
    end

    context 'application non-passported' do
      let(:application) { create :legal_aid_application, :with_negative_benefit_check_result, :checking_applicant_details, applicant: applicant, provider: provider }

      context 'permissions passported' do
        let(:provider) { create :provider, :with_passported_permissions }
        it 'allows us to continue' do
          get "/providers/applications/#{application.id}/check_benefits"
          expect(response.body).to include('CCMS')
        end
      end

      context 'no permissions' do
        let(:provider) { create :provider, :with_non_passported_permissions }
        it 'allows us to continue' do
          get "/providers/applications/#{application.id}/check_benefits"
          expect(response.body).to include(html_compare("We need to check your client's financial eligibility"))
        end
      end
    end
  end
end
