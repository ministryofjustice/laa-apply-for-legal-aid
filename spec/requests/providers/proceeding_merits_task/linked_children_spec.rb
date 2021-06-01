require 'rails_helper'

module Providers
  module ProceedingMeritsTask
    RSpec.describe LinkedChildrenController, type: :request do
      let!(:legal_aid_application) { create :legal_aid_application, :with_involved_children, :with_multiple_proceeding_types_inc_section8 }
      let(:involved_children_names) { legal_aid_application.involved_children.map(&:full_name) }
      let(:application_proceeding_type) { legal_aid_application.application_proceeding_types.find_by(proceeding_type_id: proceeding_type) }
      let(:proceeding_type) { ProceedingType.find_by(ccms_code: 'SE014') }
      let(:smtl) { create :legal_framework_merits_task_list, legal_aid_application: legal_aid_application }
      let(:login) { login_as legal_aid_application.provider }

      before do
        allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
        login
      end

      describe 'GET /providers/merits_task_list/:merits_task_list_id/linked_children' do
        subject { get providers_merits_task_list_linked_children_path(application_proceeding_type) }

        context 'when the provider is not authenticated' do
          let(:login) { nil }
          before { subject }
          it_behaves_like 'a provider not authenticated'
        end

        context 'when the provider is authenticated' do
          before { subject }

          it 'renders successfully' do
            expect(response).to have_http_status(:ok)
          end

          it 'lists all involved children\'s names in the application' do
            expect(involved_children_names.all? { |name| response.body.include? html_compare(name) }).to be true
          end
        end
      end

      describe 'PATCH /providers/merits_task_lists/:merits_task_list_id/linked_children' do
        let(:params) do
          involved_children_names.index_with { |_k| 'true' }
        end

        before { legal_aid_application&.legal_framework_merits_task_list&.mark_as_complete!(:application, :children_application) }

        subject { patch providers_merits_task_list_linked_children_path(application_proceeding_type), params: params }

        context 'all selected' do
          it 'adds involved children to the proceeding type' do
            expect { subject }.to change { application_proceeding_type.application_proceeding_type_linked_children.count }.by(3)
          end
        end

        context 'none selected' do
          let(:params) do
            params = involved_children_names.index_with { |_k| 'false' }
            params
          end

          it 'does not add involved children to the proceeding type' do
            expect { subject }.to change { application_proceeding_type.application_proceeding_type_linked_children.count }.by(0)
          end
        end

        context 'some selected' do
          let(:params) do
            params = involved_children_names.index_with { |_k| 'false' }
            params[involved_children_names.first] = 'true'
            params
          end

          it 'only adds the specified children to the proceeding type' do
            proceeding_type_involved_children = application_proceeding_type.application_proceeding_type_linked_children
            expect { subject }.to change { proceeding_type_involved_children.count }.by(1)
          end
        end

        context 'previous selections' do
          let(:update) do
            patch providers_merits_task_list_linked_children_path(application_proceeding_type), params: new_params
          end

          before { subject }

          context 'remove record' do
            let(:new_params) do
              params = involved_children_names.index_with { |_k| 'true' }
              params[involved_children_names.first] = 'false'
              params
            end

            it 'deletes a record if it is deselected' do
              expect { update }.to change { application_proceeding_type.application_proceeding_type_linked_children.count }.by(-1)
            end
          end

          context 'record already exists' do
            it 'makes no changes if already selected records are left selected' do
              expect { subject }.to change { application_proceeding_type.application_proceeding_type_linked_children.count }.by(0)
            end
          end
        end

        context 'Form submitted using Save as draft button' do
          let(:submit_button) { { draft_button: 'Save as draft' } }

          subject do
            patch providers_merits_task_list_linked_children_path(application_proceeding_type), params: params.merge(submit_button)
          end

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
              expect(legal_aid_application.legal_framework_merits_task_list.serialized_data).to_not match(/name: :children_proceeding\n\s+dependencies: \*\d\n\s+state: :complete/)
            end
          end
        end
      end
    end
  end
end
