require 'rails_helper'

module Providers
  module ProceedingMeritsTask
    RSpec.describe ChancesOfSuccessController, type: :request do
      let(:chances_of_success) { create :chances_of_success, application_proceeding_type: application_proceeding_type }
      let(:smtl) { create :legal_framework_merits_task_list, legal_aid_application: legal_aid_application }
      let(:pt_da) { create :proceeding_type, :with_real_data }
      let(:pt_s8) { create :proceeding_type, :as_section_8_child_residence }
      let(:legal_aid_application) { create :legal_aid_application, :with_proceeding_types, explicit_proceeding_types: [pt_da, pt_s8] }

      let(:application_proceeding_type) { legal_aid_application.application_proceeding_types.first }
      let(:login) { login_as legal_aid_application.provider }

      before do
        allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
        login
      end

      describe 'GET /providers/merits_task_list/:id/chances_of_success' do
        subject { get providers_merits_task_list_chances_of_success_index_path(application_proceeding_type) }

        it 'renders successfully' do
          subject
          expect(response).to have_http_status(:ok)
        end

        context 'when the provider is not authenticated' do
          let(:login) { nil }
          before { subject }
          it_behaves_like 'a provider not authenticated'
        end
      end

      describe 'POST /providers/merits_task_list/:id/chances_of_success' do
        let(:success_prospect) { :poor }
        let!(:chances_of_success) do
          create :chances_of_success, success_prospect: success_prospect, success_prospect_details: 'details', application_proceeding_type: application_proceeding_type
        end
        let(:success_likely) { 'true' }
        let(:params) do
          { proceeding_merits_task_chances_of_success: { success_likely: success_likely } }
        end
        let(:submit_button) { {} }

        subject do
          post(
            providers_merits_task_list_chances_of_success_index_path(application_proceeding_type),
            params: params.merge(submit_button)
          )
        end

        it 'associates with the application proceeding type' do
          expect(chances_of_success.application_proceeding_type).to eq application_proceeding_type
        end

        it 'sets chances_of_success to true' do
          expect { subject }.to change { chances_of_success.reload.success_likely }.to(true)
        end

        it 'sets success_prospect to likely' do
          expect { subject }.to change { chances_of_success.reload.success_prospect }.to('likely')
        end

        it 'sets success_prospect_details to nil' do
          expect { subject }.to change { chances_of_success.reload.success_prospect_details }.to(nil)
        end

        context 'when the multi-proceeding flag is true' do
          before { allow(Setting).to receive(:allow_multiple_proceedings?).and_return(true) }

          it 'redirects to the next page' do
            subject
            expect(response).to redirect_to providers_legal_aid_application_merits_task_list_path(legal_aid_application)
          end

          it 'updates the task list' do
            subject
            expect(legal_aid_application.legal_framework_merits_task_list.serialized_data).to match(/name: :chances_of_success\n\s+dependencies: \*\d\n\s+state: :complete/)
          end
        end

        it 'redirects to next page' do
          subject
          expect(response).to redirect_to(providers_legal_aid_application_check_merits_answers_path(legal_aid_application))
        end

        context 'false is selected' do
          let(:next_url) { providers_merits_task_list_success_prospects_path(application_proceeding_type) }
          let(:success_likely) { 'false' }

          it 'sets chances_of_success to false' do
            expect { subject }.to change { chances_of_success.reload.success_likely }.to(false)
          end

          it 'does not change success_prospect' do
            expect { subject }.not_to change { chances_of_success.reload.success_prospect }
          end

          it 'does not change success_prospect_details' do
            expect { subject }.not_to change { chances_of_success.reload.success_prospect_details }
          end

          it 'does not set the task to complete' do
            subject
            serialized_merits_task_list = legal_aid_application.legal_framework_merits_task_list.reload.serialized_data
            expect(serialized_merits_task_list).to_not match(/name: :chances_of_success\n\s+dependencies: \*\d\n\s+state: :complete/)
          end

          it 'redirects to next page' do
            subject
            expect(response).to redirect_to(providers_merits_task_list_success_prospects_path(application_proceeding_type))
          end

          context 'success_prospect was :likely' do
            let(:success_prospect) { :likely }

            it 'sets success_prospect to nil' do
              expect { subject }.to change { chances_of_success.reload.success_prospect }.to(nil)
            end
          end
        end

        context 'user has come from the check_merits_answer page' do
          let(:legal_aid_application) { create :legal_aid_application, :with_multiple_proceeding_types_inc_section8, :checking_merits_answers }

          it 'redirects back to the answers page' do
            subject
            expect(response).to redirect_to(providers_legal_aid_application_check_merits_answers_path(legal_aid_application))
          end
        end

        context 'nothing is selected' do
          let(:params) { {} }

          it 'renders successfully' do
            subject
            expect(response).to have_http_status(:ok)
          end

          it 'displays error' do
            subject
            expect(response.body).to include('govuk-error-summary')
          end

          it 'the response includes the error message' do
            subject
            expect(response.body).to include(I18n.t('activemodel.errors.models.proceeding_merits_task/chances_of_success.attributes.success_likely.blank'))
          end
        end

        context 'Form submitted using Save as draft button' do
          let(:submit_button) { { draft_button: 'Save as draft' } }

          it "redirects provider to provider's applications page" do
            subject
            expect(response).to redirect_to(providers_legal_aid_applications_path)
          end

          it 'sets the application as draft' do
            expect { subject }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
          end

          context 'when the multi-proceeding flag is true' do
            before { allow(Setting).to receive(:allow_multiple_proceedings?).and_return(true) }

            it 'does not set the task to complete' do
              subject
              expect(legal_aid_application.legal_framework_merits_task_list.serialized_data).to_not match(/name: :chances_of_success\n\s+dependencies: \*\d\n\s+state: :complete/)
            end
          end

          it 'updates the model' do
            subject
            chances_of_success.reload
            expect(chances_of_success.success_likely).to eq(true)
            expect(chances_of_success.success_prospect).to eq('likely')
          end
        end
      end
    end
  end
end
