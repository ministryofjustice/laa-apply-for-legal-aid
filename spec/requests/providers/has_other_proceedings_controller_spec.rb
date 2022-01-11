require 'rails_helper'

RSpec.describe Providers::HasOtherProceedingsController, type: :request do
  let(:pt1) { create :proceeding_type, :with_real_data }
  let(:pt2) { create :proceeding_type, :as_occupation_order }
  let(:legal_aid_application) { create :legal_aid_application, :with_proceeding_types, explicit_proceeding_types: [pt1, pt2] }

  let(:provider) { legal_aid_application.provider }
  let(:next_flow_step) { flow_forward_path }

  before { login_as provider }

  describe 'GET /providers/:application_id/has_other_proceedings' do
    subject! do
      get providers_legal_aid_application_has_other_proceedings_path(legal_aid_application)
    end

    it 'shows the page' do
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t('providers.has_other_proceedings.show.page_title'))
    end

    it 'shows the current number of proceedings' do
      expect(response.body).to include('You have added 2 proceedings')
    end
  end

  describe 'PATCH /providers/:application_id/has_other_proceedings' do
    subject! { patch providers_legal_aid_application_has_other_proceedings_path(legal_aid_application), params: params }

    context 'Form submitted with Save as draft button' do
      let(:params) { { legal_aid_application: { has_other_proceeding: '' }, draft_button: 'Save and come back later' } }

      it 'redirects to the list of applications' do
        expect(response).to redirect_to providers_legal_aid_applications_path
      end
    end

    context 'choose yes' do
      let(:params) { { legal_aid_application: { has_other_proceeding: 'true' } } }

      it 'redirects to the page to add another proceeding type' do
        expect(response).to redirect_to(providers_legal_aid_application_proceedings_types_path(legal_aid_application))
      end
    end

    context 'choose no' do
      let(:params) { { legal_aid_application: { has_other_proceeding: 'false' } } }

      it 'redirects to the delegated functions page' do
        expect(response).to redirect_to(providers_legal_aid_application_used_multiple_delegated_functions_path(legal_aid_application))
      end
    end

    context 'when the user is checking answers and has deleted the domestic abuse proceeding but left the section 8' do
      let(:proceeding_type) { create :proceeding_type, code: 'SE003', ccms_matter: 'Section 8 orders' }
      let(:legal_aid_application) { create :legal_aid_application, :at_checking_applicant_details, assign_lead_proceeding: false, explicit_proceeding_types: [proceeding_type] }
      let(:params) { { legal_aid_application: { has_other_proceeding: 'false' } } }

      it 'redirects to the page to add another proceeding type' do
        expect(response.body).to include(I18n.t('providers.has_other_proceedings.show.must_add_domestic_abuse'))
      end
    end

    context 'choose nothing' do
      let(:params) { { legal_aid_application: { has_other_proceeding: '' }, continue_button: 'Save and continue' } }

      it 'stays on the page if there is a validation error' do
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(I18n.t('providers.has_other_proceedings.show.error'))
      end
    end

    context 'with only Section 8 proceedings selected' do
      let(:proceeding_type) { create :proceeding_type, code: 'SE003', ccms_matter: 'Section 8 orders' }
      let(:legal_aid_application) { create :legal_aid_application, :with_proceeding_types, assign_lead_proceeding: false, explicit_proceeding_types: [proceeding_type] }

      context 'choose no' do
        let(:params) { { legal_aid_application: { has_other_proceeding: 'false' } } }

        it 'stays on the page and displays an error' do
          expect(response).to have_http_status(:ok)
          expect(response.body).to include(I18n.t('providers.has_other_proceedings.show.must_add_domestic_abuse'))
        end
      end

      context 'choose yes' do
        let(:params) { { legal_aid_application: { has_other_proceeding: 'true' } } }

        it 'redirects to the page to add another proceeding type' do
          expect(response).to redirect_to(providers_legal_aid_application_proceedings_types_path(legal_aid_application))
        end
      end
    end

    context 'with at least one domestic abuse and at least one section 8 proceeding' do
      let(:pt1) { create :proceeding_type, :as_occupation_order }
      let(:pt2) { create :proceeding_type, :as_prohibited_steps_order }
      let(:legal_aid_application) { create :legal_aid_application, :with_proceeding_types, explicit_proceeding_types: [pt1, pt2] }

      let(:params) { { legal_aid_application: { has_other_proceeding: 'false' } } }

      it 'redirects to the LASPO page' do
        expect(response).to redirect_to(providers_legal_aid_application_in_scope_of_laspo_path(legal_aid_application))
      end
    end
  end

  describe 'DELETE /providers/:application_id/has_other_proceedings' do
    let(:params) do
      {
        ccms_code: legal_aid_application.proceedings.last.ccms_code
      }
    end
    subject { delete providers_legal_aid_application_has_other_proceedings_path(legal_aid_application), params: params }

    context 'remove proceeding' do
      it 'removes one proceeding' do
        expect { subject }.to change { legal_aid_application.proceedings.count }.by(-1)
      end

      it 'leaves the correct number of remaining proceedings' do
        subject
        expect(legal_aid_application.proceedings.count).to eq 1
      end

      it 'displays the singular number of proceedings remaining' do
        subject
        expect(response.body).to include('You have added 1 proceeding')
      end

      context 'delete lead proceeding' do
        let(:params) do
          { ccms_code: legal_aid_application.proceedings.first.ccms_code }
        end

        subject { delete providers_legal_aid_application_has_other_proceedings_path(legal_aid_application), params: params }

        it 'sets a new lead application_proceeding_type when the original one is deleted' do
          subject
          expect(legal_aid_application.application_proceeding_types.order(:created_at)[0].lead_proceeding).to eq true
        end

        it 'sets a new lead proceeding when the original one is deleted' do
          subject
          expect(legal_aid_application.proceedings[0].lead_proceeding).to eq true
        end
      end
    end

    context 'remove all proceedings' do
      let(:other_params) do
        { ccms_code: legal_aid_application.proceedings.first.ccms_code }
      end

      it 'redirects to the proceedings type page if all proceeding types removed' do
        subject
        delete providers_legal_aid_application_has_other_proceedings_path(legal_aid_application), params: other_params
        expect(response).to redirect_to(providers_legal_aid_application_proceedings_types_path(legal_aid_application))
      end
    end
  end
end
