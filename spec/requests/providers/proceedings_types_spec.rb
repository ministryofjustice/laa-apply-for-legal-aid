require 'rails_helper'

RSpec.describe Providers::ProceedingsTypesController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :with_proceeding_types }
  let(:application_proceeding_type) { legal_aid_application.application_proceeding_types.first }
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
      end

      it 'returns http success' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'does not displays the proceeding types' do
        subject
        expect(unescaped_response_body).not_to include('class="selected-proceeding-types"')
      end

      it 'displays no errors' do
        subject
        expect(response.body).not_to include('govuk-input--error')
        expect(response.body).not_to include('govuk-form-group--error')
      end

      describe 'back link' do
        context "the applicant's address used s address lookup service", :vcr do
          let(:legal_aid_application) { create :legal_aid_application, :with_applicant_and_address_lookup }

          before do
            legal_aid_application.applicant.address.update!(postcode: 'YO4B0LJ')
            get providers_legal_aid_application_address_selection_path(legal_aid_application)
          end

          it 'should redirect to the address lookup page' do
            subject
            expect(response.body).to have_back_link(providers_legal_aid_application_address_selection_path(legal_aid_application, back: true))
          end
        end

        context "the applicant's address used manual entry" do
          before do
            get providers_legal_aid_application_address_path(legal_aid_application)
          end

          it 'should redirect to manual address pagelookup page' do
            subject
            expect(response.body).to have_back_link(providers_legal_aid_application_address_path(legal_aid_application, back: true))
          end
        end
      end
    end

    context '#pre_dwp_check?' do
      it 'returns true' do
        expect(described_class.new.pre_dwp_check?).to be true
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
    end
  end

  describe 'create: POST /providers/applications/:legal_aid_application_id/proceedings_types' do
    let(:params) { { continue_button: 'Continue' } }
    subject do
      post(
        providers_legal_aid_application_proceedings_types_path(legal_aid_application),
        params: params
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
      let!(:default_substantive_scope_limitation) { create :scope_limitation, :substantive_default, joined_proceeding_type: proceeding_type, meaning: 'Default substantive SL' }
      let(:params) do
        {
          id: proceeding_type.id,
          continue_button: 'Continue'
        }
      end
      let(:proceeding_type_service) { double(LegalFramework::ProceedingTypesService, add: true) }

      before { allow(LegalFramework::ProceedingTypesService).to receive(:new).with(legal_aid_application).and_return(proceeding_type_service) }

      it 'redirects to next step' do
        subject
        expect(response.body).to redirect_to(providers_legal_aid_application_has_other_proceedings_path(legal_aid_application))
      end

      it 'calls the proceeding types service' do
        expect(proceeding_type_service).to receive(:add).with(proceeding_type_id: proceeding_type.id, scope_type: :substantive)
        subject
      end

      context 'LegalFramework::ProceedingTypesService call returns false' do
        let(:proceeding_type_service) { double(LegalFramework::ProceedingTypesService, add: false) }

        before do
          allow(LegalFramework::ProceedingTypesService).to receive(:new).with(legal_aid_application).and_return(proceeding_type_service)
          allow(LeadProceedingAssignmentService).to receive(:call).with(legal_aid_application)
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
      end
    end

    context 'with save as draft' do
      let(:params) { { draft_button: 'Save as draft' } }

      it "redirects provider to provider's applications page" do
        subject
        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end

      it 'sets the application as draft' do
        expect { subject }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
      end
    end
  end

  describe 'update: PATCH /providers/applications/:legal_aid_application_id/proceedings_type/:id' do
    let!(:proceeding_type) { create(:proceeding_type) }
    let!(:default_substantive_scope_limitation) { create :scope_limitation, :substantive_default, joined_proceeding_type: proceeding_type, meaning: 'Default substantive SL' }
    let!(:default_delegated_function_scope_limitation) do
      create :scope_limitation,
             :delegated_functions_default,
             joined_proceeding_type: proceeding_type,
             meaning: 'Default delegated functions SL'
    end

    let(:params) do
      {
        legal_aid_application_id: legal_aid_application,
        id: proceeding_type
      }
    end
    let(:proceeding_type_service) { double(LegalFramework::ProceedingTypesService, add: true) }

    subject do
      patch providers_legal_aid_application_proceedings_type_path(params)
    end

    before do
      login_as provider
      allow(LegalFramework::ProceedingTypesService).to receive(:new).with(legal_aid_application).and_return(proceeding_type_service)
      subject
    end

    it 'redirects to next step' do
      subject
      expect(response.body).to redirect_to(providers_legal_aid_application_has_other_proceedings_path(legal_aid_application))
    end
  end
end
