require 'rails_helper'

RSpec.describe Providers::OpponentNamesController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:login_provider) { login_as legal_aid_application.provider }

  describe 'GET /providers/applications/:legal_aid_application_id/opponent_name' do
    subject { get providers_legal_aid_application_opponent_name_path(legal_aid_application) }

    before do
      login_provider
      subject
    end

    it 'renders successfully' do
      expect(response).to have_http_status(:ok)
    end

    context 'when not authenticated' do
      let(:login_provider) { nil }
      it_behaves_like 'a provider not authenticated'
    end

    context 'with an existing opponent' do
      let(:opponent) { create :opponent, :irish }
      let(:legal_aid_application) { create :legal_aid_application, opponent: opponent }

      it 'renders successfully' do
        expect(response).to have_http_status(:ok)
      end

      it 'displays opponent name' do
        expect(response.body).to include(html_compare(opponent.full_name))
      end
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/opponent_name' do
    let(:params) { { application_merits_task_opponent: { full_name: Faker::Name.name } } }
    let(:draft_button) { { draft_button: 'Save as draft' } }
    let(:button_clicked) { {} }
    let(:opponent) { legal_aid_application.reload.opponent }

    subject do
      patch(
        providers_legal_aid_application_opponent_name_path(legal_aid_application),
        params: params.merge(button_clicked)
      )
    end

    before { login_provider }

    it 'creates a new opponent name with the value entered' do
      expect { subject }.to change { ApplicationMeritsTask::Opponent.count }.by(1)
    end

    it 'redirects to the next page' do
      subject
      expect(response).to redirect_to(flow_forward_path)
    end

    context 'when the parameters are invalid' do
      let(:params) { { application_merits_task_opponent: { full_name: nil } } }
      before { subject }

      it 'displays error' do
        expect(response.body).to include('govuk-error-summary')
      end

      it 'renders successfully' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when not authenticated' do
      let(:login_provider) { nil }
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when save as draft selected' do
      let(:button_clicked) { draft_button }

      it 'redirects to provider draft endpoint' do
        subject
        expect(response).to redirect_to providers_legal_aid_applications_path
      end
    end
  end
end
