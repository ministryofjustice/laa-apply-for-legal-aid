require 'rails_helper'

RSpec.describe Providers::HasOtherProceedingsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_multiple_proceeding_types }
  let(:provider) { legal_aid_application.provider }
  let(:next_flow_step) { flow_forward_path }

  before { login_as provider }

  describe 'GET /providers/:application_id/has_other_proceedings' do
    subject! do
      allow(Setting).to receive(:allow_multiple_proceedings?).and_return(true)
      get providers_legal_aid_application_has_other_proceedings_path(legal_aid_application)
    end

    context 'allow multiple proceedings setting off' do
      it 'redirects to new action' do
        allow(Setting).to receive(:allow_multiple_proceedings?).and_return(false)
        get providers_legal_aid_application_has_other_proceedings_path(legal_aid_application)
        expect(response).to redirect_to(next_flow_step)
      end
    end

    context 'allow multiple proceedings setting on' do
      it 'shows the page' do
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(I18n.t('providers.has_other_proceedings.show.page_title'))
      end

      it 'shows the current number of proceedings' do
        expect(response.body).to include('You have added 2 proceedings')
      end
    end
  end

  describe 'PATCH /providers/:application_id/has_other_proceedings' do
    subject! { patch providers_legal_aid_application_has_other_proceedings_path(legal_aid_application), params: params }

    context 'Form submitted with Save as draft button' do
      let(:params) { { draft_button: 'Save as draft' } }

      it 'redirects to the list of applications' do
        expect(response).to redirect_to providers_legal_aid_applications_path
      end
    end

    context 'choose yes' do
      let(:params) { { providers_has_other_proceedings_form: { has_other_proceedings: 'true' } } }

      it 'redirects to the page to add another proceeding type' do
        expect(response).to redirect_to(providers_legal_aid_application_proceedings_types_path(legal_aid_application))
      end
    end

    context 'choose no' do
      let(:params) { { providers_has_other_proceedings_form: { has_other_proceedings: 'false' } } }

      it 'redirects to the delegated functions page' do
        expect(response).to redirect_to(providers_legal_aid_application_used_delegated_functions_path(legal_aid_application))
      end
    end

    context 'choose nothing' do
      let(:params) { { providers_has_other_proceedings_form: { has_other_proceedings: nil } } }

      it 'stays on the page if there is a validation error' do
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(I18n.t('providers.has_other_proceedings.show.error'))
      end
    end
  end

  describe 'DELETE /providers/:application_id/has_other_proceedings' do
    let(:params) { { id: legal_aid_application.proceeding_types.last.code } }
    subject { delete providers_legal_aid_application_has_other_proceedings_path(legal_aid_application), params: params }

    context 'remove proceeding' do
      it 'removes one application proceeding type' do
        expect { subject }.to change { legal_aid_application.proceeding_types.count }.by(-1)
      end

      it 'leaves the correct remaining proceeding type number' do
        subject
        expect(legal_aid_application.proceeding_types.count).to eq 1
      end

      it 'displays the singular number of proceedings remaining' do
        subject
        expect(response.body).to include('You have added 1 proceeding')
      end

      context 'delete lead proceeding' do
        let(:params) { { id: legal_aid_application.proceeding_types.first.code } }
        subject { delete providers_legal_aid_application_has_other_proceedings_path(legal_aid_application), params: params }

        it 'sets a new lead proceeding when the original one is deleted' do
          subject
          expect(legal_aid_application.application_proceeding_types[0].lead_proceeding).to eq true
        end
      end
    end

    context 'remove all proceedings' do
      let(:other_params) { { id: legal_aid_application.proceeding_types.first.code } }

      it 'redirects to the proceedings type page if all proceeding types removed' do
        subject
        delete providers_legal_aid_application_has_other_proceedings_path(legal_aid_application), params: other_params
        expect(response).to redirect_to(providers_legal_aid_application_proceedings_types_path(legal_aid_application))
      end
    end
  end
end
