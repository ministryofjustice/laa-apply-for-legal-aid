require 'rails_helper'

module Providers
  module ApplicationMeritsTask
    RSpec.describe HasOtherInvolvedChildrenController, type: :request do
      let(:application) { create :legal_aid_application }
      let(:provider) { application.provider }
      let(:child1) { create :involved_child, legal_aid_application: application }

      before { login_as provider }

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

        subject { patch providers_legal_aid_application_has_other_involved_children_path(application), params: params }

        context 'Wants to add more children' do
          let(:radio_button) { 'true' }

          it 'redirects to new involved child' do
            subject
            expect(response).to redirect_to(new_providers_legal_aid_application_involved_child_path(application))
          end
        end

        context 'does not want to add more children' do
          let(:radio_button) { 'false' }

          it 'redirects to new involved child' do
            subject
            expect(response).to redirect_to(providers_legal_aid_application_date_client_told_incident_path(application))
          end
        end

        context 'neither yes nor no selected' do
          let(:radio_button) { '' }
          it 're-renders the show page' do
            subject
            expect(response.body).to include('Do you need to add another child?')
          end
        end
      end
    end
  end
end
