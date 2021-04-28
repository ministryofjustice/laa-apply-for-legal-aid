require 'rails_helper'

module Providers
  module ProceedingMeritsTask
    RSpec.describe InvolvedChildrenController, type: :request do
      let!(:legal_aid_application) { create :legal_aid_application, :with_involved_children, :with_multiple_proceeding_types }
      let(:involved_children_names) { legal_aid_application.involved_children.map(&:full_name) }
      let(:lead_application_proceeding_type) { legal_aid_application.application_proceeding_types.first }
      let(:login) { login_as legal_aid_application.provider }

      before { login }

      describe 'GET /providers/merits_task_list/:merits_task_list_id/involved_child' do
        subject { get providers_merits_task_list_involved_child_path(lead_application_proceeding_type) }

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
            expect(involved_children_names.all? { |name| response.body.include? name }).to be true
          end
        end
      end

      describe 'PATCH /providers/merits_task_lists/:merits_task_list_id/involved_child' do
        let(:params) do
          params = involved_children_names.index_with { |_k| 'true' }
          params
        end

        subject { patch providers_merits_task_list_involved_child_path(lead_application_proceeding_type), params: params }

        context 'all selected' do
          it 'adds involved children to the proceeding type' do
            expect { subject }.to change { lead_application_proceeding_type.application_proceeding_type_involved_children.count }.by(3)
          end
        end

        context 'none selected' do
          let(:params) do
            params = involved_children_names.index_with { |_k| 'false' }
            params
          end

          it 'does not add involved children to the proceeding type' do
            expect { subject }.to change { lead_application_proceeding_type.application_proceeding_type_involved_children.count }.by(0)
          end
        end

        context 'some selected' do
          let(:params) do
            params = involved_children_names.index_with { |_k| 'false' }
            params[involved_children_names.first] = 'true'
            params
          end

          it 'only adds the specified children to the proceeding type' do
            proceeding_type_involved_children = lead_application_proceeding_type.application_proceeding_type_involved_children
            expect { subject }.to change { proceeding_type_involved_children.count }.by(1)
          end
        end

        context 'previous selections' do
          let(:update) do
            patch providers_merits_task_list_involved_child_path(lead_application_proceeding_type), params: new_params
          end

          before { subject }

          context 'remove record' do
            let(:new_params) do
              params = involved_children_names.index_with { |_k| 'true' }
              params[involved_children_names.first] = 'false'
              params
            end

            it 'deletes a record if it is deselected' do
              expect { update }.to change { lead_application_proceeding_type.application_proceeding_type_involved_children.count }.by(-1)
            end
          end

          context 'record already exists' do
            it 'makes no changes if already selected records are left selected' do
              expect { subject }.to change { lead_application_proceeding_type.application_proceeding_type_involved_children.count }.by(0)
            end
          end
        end
      end
    end
  end
end
