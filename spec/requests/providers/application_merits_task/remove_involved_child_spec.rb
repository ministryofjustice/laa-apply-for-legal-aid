require 'rails_helper'

module Providers
  module ApplicationMeritsTask
    RSpec.describe HasOtherInvolvedChildrenController, type: :request do
      let(:application) { create :legal_aid_application }
      let(:provider) { application.provider }
      let!(:child2) { create :involved_child, legal_aid_application: application }

      before { login_as provider }

      describe 'show GET /providers/applications/:legal_aid_application_id/remove_involved_child/:id' do
        subject { get providers_legal_aid_application_remove_involved_child_path(application, child2) }

        it 'displays the childs details' do
          subject
          expect(response.body).to include(html_compare(child2.full_name))
        end
      end

      describe 'update PATCH /providers/applications/:legal_aid_application_id/remove_involved_child/:id' do
        let(:params) do
          {
            binary_choice_form: {
              remove_involved_child: radio_button
            },
            legal_aid_application_id: application.id
          }
        end

        subject { patch providers_legal_aid_application_remove_involved_child_path(application, child2), params: params }

        context 'child is removed' do
          let(:radio_button) { 'true' }

          it 'deletes the involved child record' do
            expect { subject }.to change { application.involved_children.count }.by(-1)
          end

          context 'and it is the only child on the application' do
            it 'redirects to the add new involved child page' do
              subject
              expect(response).to redirect_to(new_providers_legal_aid_application_involved_child_path(application))
            end
          end

          context 'and another child exists' do
            let!(:child1) { create :involved_child, legal_aid_application: application }

            it 'redirects back to the has_other_involved_children page' do
              subject
              expect(response).to redirect_to(providers_legal_aid_application_has_other_involved_children_path(application))
            end
          end
        end

        context 'child is not removed' do
          let(:radio_button) { 'false' }
          it 'does not delete a record' do
            expect { subject }.not_to change { application.involved_children.count }
          end

          it 'redirects back to the has_other_involved_children page' do
            subject
            expect(response).to redirect_to(providers_legal_aid_application_has_other_involved_children_path(application))
          end
        end

        context 'neither yes nor no specified' do
          let(:radio_button) { '' }
          it 'does not delete a record' do
            expect { subject }.not_to change { application.involved_children.count }
          end
        end
      end
    end
  end
end
