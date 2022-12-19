require "rails_helper"

RSpec.describe Providers::HasOtherProceedingsController do
  let(:legal_aid_application) do
    create(:legal_aid_application,
           :with_proceedings,
           explicit_proceedings: %i[da001 da002])
  end

  let(:provider) { legal_aid_application.provider }
  let(:next_flow_step) { flow_forward_path }
  let(:permission) { create(:permission, :full_section_8) }
  let(:full_section_8?) { false }
  let(:mark_as_complete) { false }

  before do
    if mark_as_complete
      legal_aid_application.proceedings.in_order_of_addition.incomplete.each do |proceeding|
        proceeding.update!(used_delegated_functions: false)
      end
    end
    if full_section_8?
      legal_aid_application.provider.permissions << permission
    end
    login_as provider
  end

  describe "GET /providers/:application_id/has_other_proceedings" do
    subject! do
      get providers_legal_aid_application_has_other_proceedings_path(legal_aid_application)
    end

    it "shows the page" do
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t("providers.has_other_proceedings.show.page_title"))
    end

    it "shows the current number of proceedings" do
      expect(response.body).to include("You have added 2 proceedings")
    end
  end

  describe "PATCH /providers/:application_id/has_other_proceedings" do
    subject! { patch providers_legal_aid_application_has_other_proceedings_path(legal_aid_application), params: }

    context "Form submitted with Save as draft button" do
      let(:params) { { legal_aid_application: { has_other_proceeding: "" }, draft_button: "Save and come back later" } }

      it "redirects to the list of applications" do
        expect(response).to redirect_to providers_legal_aid_applications_path
      end
    end

    context "choose yes" do
      let(:params) { { legal_aid_application: { has_other_proceeding: "true" } } }

      it "redirects to the page to add another proceeding type" do
        expect(response).to redirect_to(providers_legal_aid_application_proceedings_types_path(legal_aid_application))
      end
    end

    context "choose no" do
      let(:params) { { legal_aid_application: { has_other_proceeding: "false" } } }

      it "redirects to the delegated functions page" do
        expect(response).to redirect_to(providers_legal_aid_application_client_involvement_type_path(legal_aid_application, legal_aid_application.proceedings.in_order_of_addition.incomplete.first))
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
        let(:proceeding) { legal_aid_application.proceedings.in_order_of_addition.incomplete.first }

        it "redirects to the client involvement type" do
          expect(response).to redirect_to(providers_legal_aid_application_client_involvement_type_path(legal_aid_application, proceeding))
        end
      end

      context "and has deleted the domestic abuse proceeding but left the section 8" do
        let(:legal_aid_application) { create(:legal_aid_application, :at_checking_applicant_details, :with_proceedings, explicit_proceedings: [:se014], set_lead_proceeding: false) }

        context "when the provider does not have full section 8 permissions" do
          it "stays on the page and displays an error" do
            expect(response).to have_http_status(:ok)
            expect(page).to have_error_message("has_other_proceeding.must_add_domestic_abuse")
          end
        end

        context "when the provider has full section 8 permissions" do
          let(:full_section_8?) { true }

          it "redirects to the first incomplete proceedings client involvement type page" do
            proceeding_id = legal_aid_application.proceedings.in_order_of_addition.incomplete.first.id
            expect(response).to redirect_to(providers_legal_aid_application_client_involvement_type_path(legal_aid_application.id, proceeding_id))
          end
        end
      end
    end

    context "choose nothing" do
      let(:params) { { legal_aid_application: { has_other_proceeding: "" }, continue_button: "Save and continue" } }

      it "stays on the page if there is a validation error" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_error_message("has_other_proceeding.blank")
      end
    end

    context "with only Section 8 proceedings selected" do
      context "choose no" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, assign_lead_proceeding: false, explicit_proceedings: [:se013]) }
        let(:params) { { legal_aid_application: { has_other_proceeding: "false" } } }

        context "when the provider does not have full section 8 permissions" do
          it "stays on the page and displays an error" do
            expect(response).to have_http_status(:ok)
            expect(page).to have_error_message("has_other_proceeding.must_add_domestic_abuse")
          end
        end

        context "when the provider has full section 8 permissions" do
          let(:full_section_8?) { true }

          it "redirects to the first incomplete proceedings client involvement type page" do
            proceeding_id = legal_aid_application.proceedings.in_order_of_addition.incomplete.first.id
            expect(response).to redirect_to(providers_legal_aid_application_client_involvement_type_path(legal_aid_application.id, proceeding_id))
          end
        end
      end

      context "choose yes" do
        let(:params) { { legal_aid_application: { has_other_proceeding: "true" } } }

        it "redirects to the page to add another proceeding type" do
          expect(response).to redirect_to(providers_legal_aid_application_proceedings_types_path(legal_aid_application))
        end
      end
    end

    context "with at least one domestic abuse and at least one section 8 proceeding" do
      let(:legal_aid_application) do
        create(:legal_aid_application,
               :with_proceedings,
               explicit_proceedings: %i[da004 se014])
      end

      let(:params) { { legal_aid_application: { has_other_proceeding: "false" } } }

      it "redirects to the first incomplete proceedings client involvement type page" do
        proceeding_id = legal_aid_application.proceedings.in_order_of_addition.incomplete.first.id
        expect(response).to redirect_to(providers_legal_aid_application_client_involvement_type_path(legal_aid_application.id, proceeding_id))
      end
    end

    def have_error_message(key)
      have_css(
        ".govuk-error-summary__list > li",
        text: I18n.t(key, scope: "activemodel.errors.models.legal_aid_application.attributes"),
      )
    end
  end

  describe "DELETE /providers/:application_id/has_other_proceedings" do
    subject { delete providers_legal_aid_application_has_other_proceedings_path(legal_aid_application), params: }

    let(:params) do
      {
        ccms_code: legal_aid_application.proceedings.last.ccms_code,
      }
    end

    context "remove proceeding" do
      it "removes one proceeding" do
        expect { subject }.to change { legal_aid_application.proceedings.count }.by(-1)
      end

      it "leaves the correct number of remaining proceedings" do
        subject
        expect(legal_aid_application.proceedings.count).to eq 1
      end

      it "displays the singular number of proceedings remaining" do
        subject
        expect(response.body).to include("You have added 1 proceeding")
      end

      context "delete lead proceeding" do
        subject { delete providers_legal_aid_application_has_other_proceedings_path(legal_aid_application), params: }

        let(:params) do
          { ccms_code: legal_aid_application.proceedings.first.ccms_code }
        end

        it "sets a new lead proceeding when the original one is deleted" do
          subject
          expect(legal_aid_application.proceedings[0].lead_proceeding).to be true
        end
      end
    end

    context "remove all proceedings" do
      let(:other_params) do
        { ccms_code: legal_aid_application.proceedings.first.ccms_code }
      end

      it "redirects to the proceedings type page if all proceeding types removed" do
        subject
        delete providers_legal_aid_application_has_other_proceedings_path(legal_aid_application), params: other_params
        expect(response).to redirect_to(providers_legal_aid_application_proceedings_types_path(legal_aid_application))
      end
    end
  end
end
