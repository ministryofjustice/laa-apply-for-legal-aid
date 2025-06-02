require "rails_helper"

RSpec.describe Providers::HasOtherProceedingsController, :vcr do
  let(:legal_aid_application) do
    create(:legal_aid_application,
           :with_proceedings,
           explicit_proceedings: %i[da001 da002])
  end

  let(:provider) { legal_aid_application.provider }
  let(:next_flow_step) { flow_forward_path }
  let(:mark_as_complete) { false }

  before do
    if mark_as_complete
      Query::IncompleteProceedings.call(legal_aid_application).in_order_of_addition.each do |proceeding|
        proceeding.update!(used_delegated_functions: false,
                           client_involvement_type_ccms_code: "A",
                           accepted_emergency_defaults: true,
                           accepted_substantive_defaults: true)
      end
    end
    login_as provider
  end

  describe "GET /providers/:application_id/has_other_proceedings" do
    it "shows the page" do
      get providers_legal_aid_application_has_other_proceedings_path(legal_aid_application)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t("providers.has_other_proceedings.show.page_title"))
    end

    it "shows the current number of proceedings" do
      get providers_legal_aid_application_has_other_proceedings_path(legal_aid_application)
      expect(response.body).to include("You have added 2 proceedings")
    end

    context "when all available proceedings have been added" do
      before do
        allow(LegalFramework::ProceedingTypes::All).to receive(:call).and_wrap_original do |original_method, *args|
          if args.any?
            raise(LegalFramework::ProceedingTypes::All::NoMatchingProceedingsFoundError)
          else
            original_method.call
          end
        end
      end

      it "renders the limited page" do
        get providers_legal_aid_application_has_other_proceedings_path(legal_aid_application)
        expect(response.body).to include "You have added all the allowed proceedings"
      end
    end
  end

  describe "PATCH /providers/:application_id/has_other_proceedings" do
    before { patch providers_legal_aid_application_has_other_proceedings_path(legal_aid_application), params: }

    context "when the Form is submitted with the Save as draft button" do
      let(:params) { { legal_aid_application: { has_other_proceeding: "" }, draft_button: "Save and come back later" } }

      it "redirects to the list of applications" do
        expect(response).to redirect_to in_progress_providers_legal_aid_applications_path
      end
    end

    context "when the provider chose yes" do
      let(:params) { { legal_aid_application: { has_other_proceeding: "true" } } }

      it "redirects to the page to add another proceeding type" do
        expect(response).to redirect_to(providers_legal_aid_application_proceedings_types_path(legal_aid_application))
      end
    end

    context "when the provider chose no" do
      let(:params) { { legal_aid_application: { has_other_proceeding: "false" } } }

      it "redirects to the delegated functions page" do
        expect(response).to redirect_to(providers_legal_aid_application_client_involvement_type_path(legal_aid_application, Query::IncompleteProceedings.call(legal_aid_application).in_order_of_addition.first))
      end
    end

    context "when the user is checking answers" do
      let(:legal_aid_application) { create(:legal_aid_application, :at_checking_applicant_details, :with_proceedings, explicit_proceedings: %i[da001 da002], set_lead_proceeding: true) }
      let(:params) { { legal_aid_application: { has_other_proceeding: "false" } } }

      context "when all proceedings are complete" do
        let(:mark_as_complete) { true }

        it "redirects to limitations" do
          expect(response).to redirect_to(providers_legal_aid_application_limitations_path(legal_aid_application))
        end
      end

      context "when there are incomplete proceedings" do
        let(:proceeding) { Query::IncompleteProceedings.call(legal_aid_application).in_order_of_addition.first }

        it "redirects to the client involvement type" do
          expect(response).to redirect_to(providers_legal_aid_application_client_involvement_type_path(legal_aid_application, proceeding))
        end
      end

      context "and has deleted the domestic abuse proceeding but left the section 8" do
        let(:legal_aid_application) { create(:legal_aid_application, :at_checking_applicant_details, :with_proceedings, explicit_proceedings: [:se014], set_lead_proceeding: false) }

        it "redirects to the first incomplete proceedings client involvement type page" do
          proceeding_id = Query::IncompleteProceedings.call(legal_aid_application).in_order_of_addition.first.id
          expect(response).to redirect_to(providers_legal_aid_application_client_involvement_type_path(legal_aid_application.id, proceeding_id))
        end
      end
    end

    context "when the provider chose nothing" do
      let(:params) { { legal_aid_application: { has_other_proceeding: "" }, continue_button: "Save and continue" } }

      it "stays on the page if there is a validation error" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_error_message("Select yes if you want to add another proceeding")
      end
    end

    context "when only Section 8 proceedings selected" do
      context "and the provider chose no" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, assign_lead_proceeding: false, explicit_proceedings: [:se013]) }
        let(:params) { { legal_aid_application: { has_other_proceeding: "false" } } }

        it "redirects to the first incomplete proceedings client involvement type page" do
          proceeding_id = Query::IncompleteProceedings.call(legal_aid_application).in_order_of_addition.first.id
          expect(response).to redirect_to(providers_legal_aid_application_client_involvement_type_path(legal_aid_application.id, proceeding_id))
        end
      end

      context "and the provider chose yes" do
        let(:params) { { legal_aid_application: { has_other_proceeding: "true" } } }

        it "redirects to the page to add another proceeding type" do
          expect(response).to redirect_to(providers_legal_aid_application_proceedings_types_path(legal_aid_application))
        end
      end
    end

    context "when at least one domestic abuse and at least one section 8 proceeding" do
      let(:legal_aid_application) do
        create(:legal_aid_application,
               :with_proceedings,
               explicit_proceedings: %i[da004 se014])
      end

      let(:params) { { legal_aid_application: { has_other_proceeding: "false" } } }

      it "redirects to the first incomplete proceedings client involvement type page" do
        proceeding_id = Query::IncompleteProceedings.call(legal_aid_application).in_order_of_addition.first.id
        expect(response).to redirect_to(providers_legal_aid_application_client_involvement_type_path(legal_aid_application.id, proceeding_id))
      end
    end
  end

  describe "DELETE /providers/:application_id/has_other_proceedings" do
    subject(:delete_request) { delete providers_legal_aid_application_has_other_proceedings_path(legal_aid_application), params: }

    let(:params) do
      {
        ccms_code: legal_aid_application.proceedings.last.ccms_code,
      }
    end

    context "when a proceeding is removed" do
      it "removes one proceeding" do
        expect { delete_request }.to change { legal_aid_application.proceedings.count }.by(-1)
      end

      it "leaves the correct number of remaining proceedings" do
        delete_request
        expect(legal_aid_application.proceedings.count).to eq 1
      end

      it "displays the singular number of proceedings remaining" do
        delete_request
        expect(response.body).to include("You have added 1 proceeding")
      end

      context "and it's the lead proceeding" do
        subject(:delete_request) { delete providers_legal_aid_application_has_other_proceedings_path(legal_aid_application), params: }

        let(:params) do
          { ccms_code: legal_aid_application.proceedings.first.ccms_code }
        end

        it "sets a new lead proceeding when the original one is deleted" do
          delete_request
          expect(legal_aid_application.proceedings[0].lead_proceeding).to be true
        end
      end
    end

    context "when all proceedings are removed" do
      let(:other_params) do
        { ccms_code: legal_aid_application.proceedings.first.ccms_code }
      end

      it "redirects to the proceedings type page if all proceeding types removed" do
        delete_request
        delete providers_legal_aid_application_has_other_proceedings_path(legal_aid_application), params: other_params
        expect(response).to redirect_to(providers_legal_aid_application_proceedings_types_path(legal_aid_application))
      end
    end
  end
end
