require 'rails_helper'

module Providers
  module ApplicationMeritsTask
    RSpec.describe HasOtherInvolvedChildrenController, type: :request do
      let(:application) { create :legal_aid_application, :with_multiple_proceedings_inc_section8 }
      let(:provider) { application.provider }
      let(:child1) { create :involved_child, legal_aid_application: application }
      let(:smtl) { create :legal_framework_merits_task_list, legal_aid_application: application }
      before do
        allow(LegalFramework::MeritsTasksService).to receive(:call).with(application).and_return(smtl)
        login_as provider
      end

      subject { get providers_legal_aid_application_has_other_involved_children_path(application) }

      describe 'show: GET /providers/applications/:legal_aid_application_id/has_other_involved_children' do
        it 'returns success' do
          subject
          expect(response).to have_http_status(:ok)
        end

        it 'displays the do you want to add more page' do
          child1
          subject
          expect(response.body).to include('You have added 1 child')
          expect(response.body).to include('Do you need to add another child?')
        end
      end

      describe 'update: PATCH /providers/applications/:legal_aid_application_id/has_other_involved_children' do
        let(:params) do
          {
            binary_choice_form: {
              has_other_involved_child: radio_button
            },
            legal_aid_application_id: application.id
          }
        end
        let(:draft_button) { { draft_button: 'Save as draft' } }
        let(:button_clicked) { {} }

        subject { patch providers_legal_aid_application_has_other_involved_children_path(application), params: params.merge(button_clicked) }

        context 'Wants to add more children' do
          let(:radio_button) { 'true' }

          it 'redirects to new involved child' do
            subject
            expect(response).to redirect_to(new_providers_legal_aid_application_involved_child_path(application))
          end

          it 'does not set the task to complete' do
            subject
            expect(application.legal_framework_merits_task_list.serialized_data).to match(/name: :children_application\n\s+dependencies: \*\d\n\s+state: :not_started/)
          end
        end

        context 'does not want to add more children' do
          let(:radio_button) { 'false' }

          it 'redirects to merits_task_list' do
            subject
            expect(response).to redirect_to(providers_legal_aid_application_merits_task_list_path(application))
          end

          it 'sets the task to complete' do
            subject
            expect(application.legal_framework_merits_task_list.serialized_data).to match(/name: :children_application\n\s+dependencies: \*\d\n\s+state: :complete/)
          end
        end

        context 'neither yes nor no selected' do
          let(:radio_button) { '' }
          it 're-renders the show page' do
            subject
            expect(response.body).to include('Do you need to add another child?')
          end

          it 'does not set the task to complete' do
            subject
            expect(application.legal_framework_merits_task_list.serialized_data).to match(/name: :children_application\n\s+dependencies: \*\d\n\s+state: :not_started/)
          end
        end
      end
    end
  end
end
