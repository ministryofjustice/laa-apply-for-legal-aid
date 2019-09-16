require 'rails_helper'

RSpec.describe Providers::CapitalAssessmentResultsController, type: :request do
  describe 'GET  /providers/applications/:legal_aid_application_id/capital_assessment_result' do
    let(:capital_assessment_result) { :eligible }
    let(:legal_aid_application) { create :legal_aid_application, capital_assessment_result: capital_assessment_result }
    let(:applicant_name) { legal_aid_application.applicant_full_name }
    let(:locale_scope) { 'providers.capital_assessment_results' }

    let(:login_provider) { login_as legal_aid_application.provider }
    let(:before_tasks) do
      login_provider
      subject
    end

    subject { get providers_legal_aid_application_capital_assessment_result_path(legal_aid_application) }

    before { before_tasks }

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'displays the correct result' do
      expect(unescaped_response_body).to include(I18n.t('eligible.heading', name: applicant_name, scope: locale_scope))
    end

    context 'when not eligible' do
      let(:capital_assessment_result) { :not_eligible }

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'displays the correct result' do
        expect(unescaped_response_body).to include(I18n.t('not_eligible.heading', name: applicant_name, scope: locale_scope))
      end
    end

    context 'when contribution required' do
      let(:capital_assessment_result) { :contribution_required }

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'displays the correct result' do
        expect(unescaped_response_body).to include(I18n.t('contribution_required.heading', name: applicant_name, scope: locale_scope))
      end
    end

    context 'unauthenticated' do
      let(:before_tasks) { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'unknown result' do
      let(:capital_assessment_result) { nil }
      let(:before_tasks) { login_provider }

      it 'raises error' do
        expect { subject }.to raise_error(/Unknown capital_assessment_result/)
      end
    end
  end
end
