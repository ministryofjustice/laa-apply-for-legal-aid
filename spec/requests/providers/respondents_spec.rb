require 'rails_helper'

RSpec.describe Providers::RespondentsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:login_provider) { login_as legal_aid_application.provider }

  describe 'GET /providers/applications/:legal_aid_application_id/respondent' do
    subject { get providers_legal_aid_application_respondent_path(legal_aid_application) }

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

    context 'with an existing respondent' do
      let(:respondent) { create :respondent }
      let(:legal_aid_application) { create :legal_aid_application, respondent: respondent }

      it 'renders successfully' do
        expect(response).to have_http_status(:ok)
      end

      it 'displays respondent data' do
        expect(response.body).to include(respondent.understands_terms_of_court_order_details)
        expect(response.body).to include(respondent.warning_letter_sent_details)
        expect(response.body).to include(respondent.police_notified_details)
        expect(response.body).to include(respondent.bail_conditions_set_details)
      end
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/respondent' do
    let(:sample_respondent) { build :respondent, :police_notified_true }
    let(:params) do
      {
        respondent: {
          understands_terms_of_court_order: sample_respondent.understands_terms_of_court_order.to_s,
          understands_terms_of_court_order_details: sample_respondent.understands_terms_of_court_order_details,
          warning_letter_sent: sample_respondent.warning_letter_sent.to_s,
          warning_letter_sent_details: sample_respondent.warning_letter_sent_details,
          police_notified: sample_respondent.police_notified.to_s,
          police_notified_details_true: sample_respondent.police_notified_details,
          bail_conditions_set: sample_respondent.bail_conditions_set.to_s,
          bail_conditions_set_details: sample_respondent.bail_conditions_set_details
        }
      }
    end
    let(:draft_button) { { draft_button: 'Save as draft' } }
    let(:button_clicked) { {} }
    let(:respondent) { legal_aid_application.reload.respondent }

    subject do
      patch(
        providers_legal_aid_application_respondent_path(legal_aid_application),
        params: params.merge(button_clicked)
      )
    end

    before { login_provider }

    it 'creates a new respondent with the values entered' do
      expect { subject }.to change { Respondent.count }.by(1)
      expect(respondent.understands_terms_of_court_order).to eq(sample_respondent.understands_terms_of_court_order)
      expect(respondent.understands_terms_of_court_order_details).to eq(sample_respondent.understands_terms_of_court_order_details)
      expect(respondent.warning_letter_sent).to eq(sample_respondent.warning_letter_sent)
      expect(respondent.warning_letter_sent_details).to eq(sample_respondent.warning_letter_sent_details)
      expect(respondent.police_notified).to eq(sample_respondent.police_notified)
      expect(respondent.police_notified_details).to eq(sample_respondent.police_notified_details)
      expect(respondent.bail_conditions_set).to eq(sample_respondent.bail_conditions_set)
      expect(respondent.bail_conditions_set_details).to eq(sample_respondent.bail_conditions_set_details)
    end

    it 'redirects to the next page' do
      subject
      expect(response).to redirect_to(flow_forward_path)
    end

    context 'when not authenticated' do
      let(:login_provider) { nil }
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when incomplete' do
      let(:sample_respondent) { Respondent.new }

      it 'renders show' do
        subject
        expect(response).to have_http_status(:ok)
      end
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
