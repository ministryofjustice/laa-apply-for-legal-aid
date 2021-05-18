require 'rails_helper'

RSpec.describe Providers::InScopeOfLasposController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_multiple_proceeding_types }
  let(:provider) { legal_aid_application.provider }
  let(:next_flow_step) { flow_forward_path }

  before { login_as provider }

  describe 'GET /providers/:application_id/in_scope_of_laspo' do
    subject { get providers_legal_aid_application_in_scope_of_laspo_path(legal_aid_application) }

    context 'allow multiple proceedings setting off' do
      before do
        allow(Setting).to receive(:allow_multiple_proceedings?).and_return(false)
        subject
      end

      it 'redirects to new action' do
        expect(response).to redirect_to(next_flow_step)
      end
    end

    context 'allow multiple proceedings setting on' do
      before do
        allow(Setting).to receive(:allow_multiple_proceedings?).and_return(true)
        subject
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'displays the page' do
        expect(unescaped_response_body).to include(I18n.t('providers.in_scope_of_laspos.show.page_title'))
      end
    end
  end

  describe 'PATCH /providers/:application_id/in_scope_of_laspo' do
    subject { patch providers_legal_aid_application_in_scope_of_laspo_path(legal_aid_application), params: params }

    context 'with multiple proceedings flag on' do
      before do
        allow(Setting).to receive(:allow_multiple_proceedings?).and_return(true)
        subject
      end

      context 'choose yes' do
        let(:params) { { legal_aid_application: { in_scope_of_laspo: true } } }

        it 'updates the record' do
          expect(legal_aid_application.reload.in_scope_of_laspo).to eq(true)
        end

        it 'redirects to the next page' do
          expect(response).to redirect_to(next_flow_step)
        end
      end

      context 'choose no' do
        let(:params) { { legal_aid_application: { in_scope_of_laspo: false } } }

        it 'updates the record' do
          expect(legal_aid_application.reload.in_scope_of_laspo).to eq(false)
        end

        it 'redirects to the next page' do
          expect(response).to redirect_to(next_flow_step)
        end
      end

      context 'choose nothing' do
        let(:params) { { legal_aid_application: { in_scope_of_laspo: nil } } }

        it 'stays on the page if there is a validation error' do
          expect(response).to have_http_status(:ok)
          expect(unescaped_response_body).to include(I18n.t('activemodel.errors.models.legal_aid_application.attributes.in_scope_of_laspo.blank'))
        end
      end
    end
  end
end
