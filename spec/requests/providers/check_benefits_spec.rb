require 'rails_helper'

RSpec.describe 'check benefits requests', type: :request do
  let(:last_name) { 'WALKER' }
  let(:date_of_birth) { '1980/01/10'.to_date }
  let(:national_insurance_number) { 'JA293483A' }
  let(:applicant) { create :applicant, last_name: last_name, date_of_birth: date_of_birth, national_insurance_number: national_insurance_number }
  let(:application) { create :application, applicant: applicant }
  let(:address_lookup_used) { true }

  describe 'GET /providers/applications/:application_id/check_benefits', :vcr do
    let(:get_request) { get "/providers/applications/#{application.id}/check_benefits" }
    subject { get "/providers/applications/#{application.id}/check_benefits" }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        create :address, applicant: applicant, lookup_used: address_lookup_used
        login_as create(:provider)
      end

      it 'returns http success' do
        subject
        expect(response).to have_http_status(:ok)
      end

      # context 'when the check_benefit_results is positive' do
      #   before do
      #     allow_any_instance_of(BenefitCheckResult).to receive(:positive?).and_return(true)
      #   end
      #   it 'displays a link to own home' do
      #     perform_request
      #     expect(response.body).to include(providers_legal_aid_application_own_home_path(application))
      #   end
      # end

      # context 'when the check_benefit_results is negative' do
      #   before do
      #     allow_any_instance_of(BenefitCheckResult).to receive(:positive?).and_return(false)
      #   end
      #   it 'displays a link to online banking' do
      #     perform_request
      #     expect(response.body).to include(providers_legal_aid_application_online_banking_path(application))
      #   end
      # end

      context 'when the check_benefit_result does not exist' do
        it 'generates a new check_benefit_result' do
          expect { subject }.to change { BenefitCheckResult.count }.by(1)
        end
      end

      context 'when the check_benefit_result already exists' do
        let!(:benefit_check_result) { create :benefit_check_result, legal_aid_application: application }

        it 'does not generate a new one' do
          expect_any_instance_of(BenefitCheckService).not_to receive(:call).and_call_original
          expect { subject }.to_not change { BenefitCheckResult.count }
        end

        context 'and the applicant has since been modified' do
          before { applicant.update(first_name: Faker::Name.first_name) }
          let!(:benefit_check_result) { create :benefit_check_result, legal_aid_application: application }

          it 'updates check_benefit_result' do
            expect_any_instance_of(BenefitCheckService).to receive(:call).and_call_original
            subject
          end
        end
      end
    end
  end

  describe 'PATCH /providers/applications/:application_id/check_benefit' do
    before { patch providers_legal_aid_application_check_benefit_path(application.id), params: params }

    subject { patch providers_legal_aid_application_check_benefit_path(application.id), params: params }

    context 'when the provider is authenticated' do
      before do
        login_as create(:provider)
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

          it 'displays the own home page' do
            expect(response).to redirect_to providers_legal_aid_application_own_home_path(application)
          end
        end

        context 'when the check benefit result is negative' do
          let(:application) { create :legal_aid_application, :with_negative_benefit_check_result }

          it 'displays the online banking page' do
            expect(response).to redirect_to providers_legal_aid_application_online_banking_path(application)
          end
        end

        context 'when the check benefit result is undetermined' do
          let(:application) { create :legal_aid_application, :with_undetermined_benefit_check_result }

          it 'displays the online banking page' do
            expect(response).to redirect_to providers_legal_aid_application_online_banking_path(application)
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
end
