require 'rails_helper'

RSpec.describe Providers::CapitalAssessmentResultsController, type: :request do
  describe 'GET  /providers/applications/:legal_aid_application_id/capital_assessment_result' do
    let(:cfe_result) { create :cfe_v1_result }
    let(:legal_aid_application) { cfe_result.legal_aid_application }
    let(:applicant_name) { legal_aid_application.applicant_full_name }
    let(:locale_scope) { 'providers.capital_assessment_results' }

    let(:login_provider) { login_as legal_aid_application.provider }
    let(:before_tasks) do
      login_provider
      subject
    end

    subject { get providers_legal_aid_application_capital_assessment_result_path(legal_aid_application) }

    before { before_tasks }

    context 'no restrictions' do
      context 'eligible' do
        it 'returns http success' do
          expect(response).to have_http_status(:ok)
        end

        it 'displays the correct result' do
          expect(unescaped_response_body).to include(I18n.t('eligible.heading', name: applicant_name, scope: locale_scope))
        end
      end

      context 'when not eligible' do
        let(:cfe_result) { create :cfe_v1_result, :not_eligible }

        it 'returns http success' do
          expect(response).to have_http_status(:ok)
        end

        it 'displays the correct result' do
          expect(unescaped_response_body).to include(I18n.t('not_eligible.heading', name: applicant_name, scope: locale_scope))
        end
      end

      context 'when contribution required' do
        let(:cfe_result) { create :cfe_v1_result, :contribution_required }

        it 'returns http success' do
          expect(response).to have_http_status(:ok)
        end

        it 'displays the correct result' do
          expect(unescaped_response_body).to include(I18n.t('contribution_required.heading', name: applicant_name, scope: locale_scope))
        end
      end
    end

    context 'with restrictions' do
      let(:before_tasks) do
        create :applicant, legal_aid_application: legal_aid_application, first_name: 'Stepriponikas', last_name: 'Bonstart'
        legal_aid_application.update has_restrictions: true, restrictions_details: 'Blah blah'
        login_provider
        subject
      end

      context 'eligible' do
        it 'returns http success' do
          expect(response).to have_http_status(:ok)
        end

        it 'displays the correct result' do
          expect(unescaped_response_body).to include(I18n.t('eligible.heading', name: applicant_name, scope: locale_scope))
        end
      end

      context 'when contribution required' do
        let(:cfe_result) { create :cfe_v1_result, :contribution_required }

        it 'returns http success' do
          expect(response).to have_http_status(:ok)
        end

        it 'displays manual check required' do
          expect(unescaped_response_body).to include(I18n.t('manual_check_required.heading', name: applicant_name, scope: locale_scope))
        end
      end
    end

    context 'unauthenticated' do
      let(:before_tasks) { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'unknown result' do
      let(:cfe_result) { create :cfe_v1_result, result: {}.to_json }
      let(:before_tasks) { login_provider }

      it 'raises error' do
        expect { subject }.to raise_error(/Unknown capital_assessment_result/)
      end
    end
  end
end
