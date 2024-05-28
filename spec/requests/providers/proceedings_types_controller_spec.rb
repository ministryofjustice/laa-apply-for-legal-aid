require "rails_helper"

RSpec.describe Providers::ProceedingsTypesController, :vcr do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_proceedings) }
  let(:provider) { legal_aid_application.provider }

  describe "index: GET /providers/applications/:legal_aid_application_id/proceedings_types" do
    subject(:get_request) { get providers_legal_aid_application_proceedings_types_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      it "returns http success" do
        get_request
        expect(response).to have_http_status(:ok)
      end

      it "does not displays the proceeding types" do
        get_request
        expect(unescaped_response_body).not_to include('class="selected-proceeding-types"')
      end

      it "displays no errors" do
        get_request
        expect(response.body).not_to include("govuk-input--error")
        expect(response.body).not_to include("govuk-form-group--error")
      end

      describe "back link" do
        context "when the applicant's address used address lookup service", :vcr do
          let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_address_lookup) }

          before do
            legal_aid_application.applicant.address.update!(postcode: "YO4B0LJ")
            get providers_legal_aid_application_correspondence_address_selection_path(legal_aid_application)
          end

          it "redirects to the address lookup page" do
            get_request
            expect(response.body).to have_back_link(providers_legal_aid_application_correspondence_address_selection_path(legal_aid_application, back: true))
          end
        end

        context "when the applicant's address used manual entry" do
          before do
            get providers_legal_aid_application_correspondence_address_manual_path(legal_aid_application)
          end

          it "redirects to the manual address page lookup page" do
            get_request
            expect(response.body).to have_back_link(providers_legal_aid_application_correspondence_address_manual_path(legal_aid_application, back: true))
          end
        end
      end
    end
  end

  describe "create: POST /providers/applications/:legal_aid_application_id/proceedings_types" do
    subject(:patch_request) do
      post(
        providers_legal_aid_application_proceedings_types_path(legal_aid_application),
        params:,
      )
    end

    let(:params) { { continue_button: "Continue" } }

    before do
      login_as provider
    end

    it "renders index" do
      patch_request
      expect(response).to have_http_status(:ok)
    end

    it "displays errors" do
      patch_request
      expect(response.body).to include("govuk-input--error")
      expect(response.body).to include("govuk-form-group--error")
    end

    context "with proceedings" do
      let!(:legal_aid_application) do
        create(:legal_aid_application,
               :with_applicant,
               :with_proceedings,
               set_lead_proceeding: :da001)
      end
      let(:proceeding) { legal_aid_application.proceedings.find_by(ccms_code: "DA001") }
      let(:params) do
        {
          id: proceeding.ccms_code,
          continue_button: "Continue",
        }
      end
      let(:add_proceeding_service) { instance_double(LegalFramework::AddProceedingService, call: true) }

      before { allow(LegalFramework::AddProceedingService).to receive(:new).with(legal_aid_application).and_return(add_proceeding_service) }

      it "redirects to next step" do
        patch_request
        expect(response).to have_http_status(:redirect)
      end

      it "calls the add proceeding service" do
        expect(add_proceeding_service).to receive(:call).with(ccms_code: proceeding.ccms_code)
        patch_request
      end

      context "when LegalFramework::ProceedingTypesService call returns false" do
        let(:proceeding_type_service) { instance_double(LegalFramework::ProceedingTypesService, add: false) }
        let(:add_proceeding_service) { instance_double(LegalFramework::AddProceedingService, call: false) }

        before do
          allow(LegalFramework::AddProceedingService).to receive(:new).with(legal_aid_application).and_return(add_proceeding_service)
          allow(LegalFramework::LeadProceedingAssignmentService).to receive(:call).with(legal_aid_application)
        end

        it "renders index" do
          patch_request
          expect(response).to have_http_status(:ok)
        end

        it "displays errors" do
          patch_request
          expect(response.body).to include("govuk-input--error")
          expect(response.body).to include("govuk-form-group--error")
        end
      end
    end

    context "with save as draft" do
      let(:params) { { draft_button: "Save as draft" } }

      it "redirects provider to provider's applications page" do
        patch_request
        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end

      it "sets the application as draft" do
        expect { patch_request }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
      end
    end
  end
end
