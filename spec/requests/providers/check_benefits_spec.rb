require 'rails_helper'

class EnvironmentPermutation
  attr_reader :env, :setting, :application, :permissions, :expected_result

  EXPECTED_TEXTS = {
    continue: 'receives benefits that qualify for legal aid',
    ccms: "You need to use <abbr title='Client and Cost Management System'>CCMS</abbr> for this application",
    need_to_check: 'We need to check your client'
  }.freeze

  def initialize(env:, setting:, application:, permissions:, expected_result:)
    @env = env
    @setting = setting
    @application = application
    @permissions = permissions
    @expected_result = expected_result
  end

  def benefit_check_result
    @application == :passported ? :positive : :negative
  end

  def provider_permissions
    case @permissions
    when :passported
      :with_passported_permissions
    when :non_passported
      :with_non_passported_permissions
    else
      :with_no_permissions
    end
  end

  def expected_text
    EXPECTED_TEXTS[@expected_result]
  end
end

RSpec.describe Providers::CheckBenefitsController, type: :request do
  let(:last_name) { 'WALKER' }
  let(:date_of_birth) { '1980/01/10'.to_date }
  let(:national_insurance_number) { 'JA293483A' }
  let(:applicant) { create :applicant, last_name: last_name, date_of_birth: date_of_birth, national_insurance_number: national_insurance_number }
  let(:application) { create :application, :checking_applicant_details, applicant: applicant }
  let(:address_lookup_used) { true }
  let(:login) { login_as application.provider }
  let(:env_allow_non_passported_route) { [true, false].sample }
  let(:setting_allow_non_passported_route) { [true, false].sample }
  let(:provider) { create :provider }

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
          expect(response).to redirect_to providers_legal_aid_application_non_passported_client_instructions_path(application)
        end
      end

      context 'when the check benefit result is undetermined' do
        let(:application) { create :legal_aid_application, :with_undetermined_benefit_check_result }

        it 'displays the online banking page' do
          expect(response).to redirect_to providers_legal_aid_application_non_passported_client_instructions_path(application)
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

  context 'decision tree: allowed to continue or use ccms?' do
    permutations = [
      EnvironmentPermutation.new(env: true, setting: true, application: :passported, permissions: :passported, expected_result: :continue),
      EnvironmentPermutation.new(env: true, setting: true, application: :passported, permissions: :none, expected_result: :ccms),
      EnvironmentPermutation.new(env: true, setting: true, application: :non_passported, permissions: :passported, expected_result: :ccms),
      EnvironmentPermutation.new(env: true, setting: true, application: :non_passported, permissions: :non_passported, expected_result: :need_to_check),

      EnvironmentPermutation.new(env: true, setting: false, application: :passported, permissions: :passported, expected_result: :continue),
      EnvironmentPermutation.new(env: true, setting: false, application: :passported, permissions: :none, expected_result: :ccms),
      EnvironmentPermutation.new(env: true, setting: false, application: :non_passported, permissions: :passported, expected_result: :ccms),
      EnvironmentPermutation.new(env: true, setting: false, application: :non_passported, permissions: :non_passported, expected_result: :ccms),

      EnvironmentPermutation.new(env: false, setting: false, application: :passported, permissions: :passported, expected_result: :continue),
      EnvironmentPermutation.new(env: false, setting: false, application: :passported, permissions: :none, expected_result: :ccms),
      EnvironmentPermutation.new(env: false, setting: false, application: :non_passported, permissions: :passported, expected_result: :ccms),
      EnvironmentPermutation.new(env: false, setting: false, application: :non_passported, permissions: :non_passported, expected_result: :ccms),

      # # The environment setting is no longer used - so same results as if it were true in first section above
      EnvironmentPermutation.new(env: false, setting: true, application: :passported, permissions: :passported, expected_result: :continue),
      EnvironmentPermutation.new(env: false, setting: true, application: :passported, permissions: :none, expected_result: :ccms),
      EnvironmentPermutation.new(env: false, setting: true, application: :non_passported, permissions: :passported, expected_result: :ccms),
      EnvironmentPermutation.new(env: false, setting: true, application: :non_passported, permissions: :non_passported, expected_result: :need_to_check)
    ]
    permutations.each do |perm|
      it 'outputs the expected text' do
        Setting.setting.update!(allow_non_passported_route: perm.setting)
        allow(Rails.configuration.x).to receive(:allow_non_passported_route).and_return(perm.env)
        provider = create :provider, perm.provider_permissions
        provider.firm.permissions = []
        application = create :application, :checking_applicant_details, applicant: applicant, provider: provider
        create :benefit_check_result, perm.benefit_check_result, legal_aid_application: application

        login_as application.provider
        get "/providers/applications/#{application.id}/check_benefits"
        expect(response.body).to include(perm.expected_text)
      end
    end
  end
end
