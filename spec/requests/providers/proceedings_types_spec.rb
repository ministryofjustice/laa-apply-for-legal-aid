require 'rails_helper'

RSpec.describe 'providers legal aid application proceedings type requests', type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
  let(:provider) { legal_aid_application.provider }

  describe 'index: GET /providers/applications/:legal_aid_application_id/proceedings_types' do
    subject { get providers_legal_aid_application_proceedings_types_path(legal_aid_application) }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'does not displays the proceeding types' do
        expect(unescaped_response_body).not_to include('class="selected-proceeding-types"')
      end

      it 'displays no errors' do
        subject
        expect(response.body).not_to include('govuk-input--error')
        expect(response.body).not_to include('govuk-form-group--error')
      end

      describe 'back link' do
        context "the applicant's address used s address lookup service" do
          let(:legal_aid_application) { create :legal_aid_application, :with_applicant_and_address_lookup }

          it 'should redirect to the address lookup page' do
            expect(response.body).to have_back_link(providers_legal_aid_application_address_selection_path(legal_aid_application))
          end
        end

        context "the applicant's address used manual entry" do
          it 'should redirect to manual address pagelookup page' do
            expect(response.body).to have_back_link(providers_legal_aid_application_address_path(legal_aid_application))
          end
        end
      end
    end

    context 'when application has proceeding types' do
      let!(:proceeding_type) { create :proceeding_type, legal_aid_applications: [legal_aid_application] }
      before do
        login_as provider
        subject
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'displays the proceeding types' do
        expect(unescaped_response_body).to include('class="selected-proceeding-types"')
      end
    end
  end

  describe 'create: POST /providers/applications/:legal_aid_application_id/proceedings_types' do
    subject do
      post(
        providers_legal_aid_application_proceedings_types_path(legal_aid_application),
        params: { continue_button: 'Continue' }
      )
    end

    before do
      login_as provider
    end

    it 'renders index' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'displays errors' do
      subject
      expect(response.body).to include('govuk-input--error')
      expect(response.body).to include('govuk-form-group--error')
    end

    context 'with proceeding types' do
      let!(:proceeding_type) { create :proceeding_type, legal_aid_applications: [legal_aid_application] }

      it 'redirects to next step' do
        subject
        expect(response).to redirect_to(providers_legal_aid_application_check_provider_answers_path(legal_aid_application))
      end
    end
  end

  describe 'update: PATCH /providers/applications/:legal_aid_application_id/proceedings_type/:id' do
    let(:code) { 'PR0001' }
    let!(:proceeding_type) { create(:proceeding_type) }
    let(:params) do
      {
        legal_aid_application_id: legal_aid_application,
        id: proceeding_type
      }
    end
    subject do
      patch providers_legal_aid_application_proceedings_type_path(params)
    end

    before do
      login_as provider
      subject
    end

    it 'displays the change via index' do
      expect(response).to redirect_to(providers_legal_aid_application_proceedings_types_path(legal_aid_application))
    end

    it 'associates proceeding type with legal aid application' do
      expect(legal_aid_application.reload.proceeding_types).to include(proceeding_type)
    end
  end

  describe 'destroy: DELETE /providers/applications/:legal_aid_application_id/proceedings_type/:id' do
    let!(:proceeding_type) { create(:proceeding_type, legal_aid_applications: [legal_aid_application]) }
    let(:params) do
      {
        legal_aid_application_id: legal_aid_application,
        id: proceeding_type
      }
    end
    subject do
      delete providers_legal_aid_application_proceedings_type_path(params)
    end

    before do
      login_as provider
      subject
    end

    it 'displays the change via index' do
      expect(response).to redirect_to(providers_legal_aid_application_proceedings_types_path(legal_aid_application))
    end

    it 'associates proceeding type with legal aid application' do
      expect(legal_aid_application.reload.proceeding_types).not_to include(proceeding_type)
    end
  end
end
