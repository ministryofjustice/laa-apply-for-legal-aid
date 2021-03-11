require 'rails_helper'

RSpec.describe Providers::ReceivedBenefitConfirmationsController, type: :request do
  let(:application) { create(:legal_aid_application, :with_proceeding_types, :with_applicant_and_address) }
  let(:application_id) { application.id }

  describe 'GET /providers/applications/:legal_aid_application_id/received_benefit_confirmation' do
    subject { get "/providers/applications/#{application_id}/received_benefit_confirmation" }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        login_as application.provider
        subject
      end

      it 'returns success' do
        expect(response).to be_successful
      end

      it 'displays the correct page' do
        expect(unescaped_response_body).to include('Which passporting benefit does your client receive?')
      end
    end
  end
end

# describe 'PATCH providers/applications/:id/policy_disregards' do
#     let(:params) do
#       {
#         policy_disregards: {
#           england_infected_blood_support: true,
#           vaccine_damage_payments: false,
#           variant_creutzfeldt_jakob_disease: false,
#           criminal_injuries_compensation_scheme: false,
#           national_emergencies_trust: false,
#           we_love_manchester_emergency_fund: false,
#           london_emergencies_trust: false,
#           none_selected: ''
#         }
#       }
#     end
#     context 'when the provider is authenticated' do
#       before do
#         login_as provider
#       end

#       context 'Submitted with Continue button' do
#         let(:submit_button) do
#           { continue_button: 'Continue' }
#         end

#         before do
#           patch providers_legal_aid_application_policy_disregards_path(policy.legal_aid_application), params: params.merge(submit_button)
#         end

#         context 'valid params' do
#           it 'updates the record' do
#             policy.reload
#             expect(policy.england_infected_blood_support).to be true
#             expect(policy.vaccine_damage_payments).to be false
#             expect(policy.variant_creutzfeldt_jakob_disease).to be false
#             expect(policy.criminal_injuries_compensation_scheme).to be false
#             expect(policy.national_emergencies_trust).to be false
#             expect(policy.we_love_manchester_emergency_fund).to be false
#             expect(policy.london_emergencies_trust).to be false
#           end
#         end
#         context 'provider checking their answers' do
#           let(:application) { create :legal_aid_application, :with_applicant, :with_passported_state_machine, :checking_passported_answers }

#           it 'redirects to check passported answers' do
#             expect(response).to redirect_to(providers_legal_aid_application_check_passported_answers_path)
#           end
#         end

#         context "provider checking citizen's answers" do
#           let(:application) { create :legal_aid_application, :with_applicant, :with_non_passported_state_machine, :checking_non_passported_means }

#           it 'redirects to means summary page' do
#             subject
#             expect(response).to redirect_to(providers_legal_aid_application_means_summary_path)
#           end
#         end
#       end

#       context 'has nothing' do
#         let(:application) { create :legal_aid_application, :with_positive_benefit_check_result }
#         let(:policy) { create :policy_disregards, legal_aid_application: application }
#         let(:none_selected) { 'true' }
#         let(:empty_params) do
#           {
#             policy_disregards: {
#               england_infected_blood_support: '',
#               vaccine_damage_payments: '',
#               variant_creutzfeldt_jakob_disease: '',
#               criminal_injuries_compensation_scheme: '',
#               national_emergencies_trust: '',
#               we_love_manchester_emergency_fund: '',
#               london_emergencies_trust: '',
#               none_selected: none_selected
#             }
#           }
#         end
#         let(:submit_button) { { continue_button: 'Continue' } }

#         before do
#           patch providers_legal_aid_application_policy_disregards_path(policy.legal_aid_application), params: empty_params.merge(submit_button)
#         end

#         context 'with none of these checkbox selected' do
#           let(:none_selected) { 'true' }

#           it 'redirects to check passported answers' do
#             expect(application.reload.policy_disregards.england_infected_blood_support?).to be false
#             expect(response).to redirect_to(providers_legal_aid_application_check_passported_answers_path(application))
#           end
#         end
#         context 'and none of these checkbox is not selected' do
#           let(:none_selected) { '' }

#           it 'the response includes the error message' do
#             expect(response.body).to include(I18n.t('activemodel.errors.models.policy_disregards.attributes.base.none_selected'))
#           end
#         end
#       end
#     end
#   end
