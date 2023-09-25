require "rails_helper"

RSpec.describe Providers::CheckClientDetailsController do
  let(:application) { create(:legal_aid_application, :with_proceedings, :with_applicant_and_address) }
  let(:application_id) { application.id }

  describe "GET /providers/applications/:legal_aid_application_id/check_client_details" do
    subject(:get_request) { get "/providers/applications/#{application_id}/check_client_details" }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as application.provider
        get_request
      end

      it "returns success" do
        expect(response).to be_successful
      end

      it "displays the applicant's full name" do
        full_name = "#{application.applicant.first_name} #{application.applicant.last_name}"
        expect(unescaped_response_body).to include(full_name)
      end

      it "displays the applicant date of birth in the required format" do
        dob_formatted = application.applicant.date_of_birth.strftime("%e %B %Y")
        expect(unescaped_response_body).to include(dob_formatted)
      end

      it "displays the applicant national insurance number" do
        ni_number = application.applicant.national_insurance_number
        expect(unescaped_response_body).to include(ni_number)
      end
    end

    context "when the client has a partner, flag is on and the provider previously selected joint benefit with partner" do
      let(:application) { create(:legal_aid_application, :with_partner_and_joint_benefit, :with_proceedings, :at_checking_applicant_details) }
      let(:partner) { application.partner }

      before do
        login_as application.provider
        allow(Setting).to receive(:partner_means_assessment?).and_return(true)
        get_request
      end

      it "displays the partner's full name" do
        full_name = "#{partner.first_name} #{partner.last_name}"
        expect(unescaped_response_body).to include(full_name)
      end

      it "displays the partner date of birth in the required format" do
        dob_formatted = partner.date_of_birth.strftime("%e %B %Y")
        expect(unescaped_response_body).to include(dob_formatted)
      end

      it "displays the partner national insurance number" do
        ni_number = partner.national_insurance_number
        expect(unescaped_response_body).to include(ni_number)
      end
    end

    context "when the client does not have a partner" do
      before do
        login_as application.provider
        get_request
      end

      it "does not display partner details section" do
        expect(unescaped_response_body).not_to include(I18n.t("providers.check_client_details.show.h2_partner"))
      end
    end

    context "when the partner means journey flag is turned off" do
      before do
        login_as application.provider
        allow(Setting).to receive(:partner_means_assessment?).and_return(true)
        get_request
      end

      it "does not display partner details section" do
        expect(unescaped_response_body).not_to include(I18n.t("providers.check_client_details.show.h2_partner"))
      end
    end

    context "when the partner means flag is on and the client has a partner but the benefit is not joint" do
      let(:application) { create(:legal_aid_application, :with_applicant_and_partner, :with_proceedings, :at_checking_applicant_details) }

      before do
        login_as application.provider
        allow(Setting).to receive(:partner_means_assessment?).and_return(true)
        get_request
      end

      it "does not display partner details section" do
        expect(unescaped_response_body).not_to include(I18n.t("providers.check_client_details.show.h2_partner"))
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/check_client_details" do
    subject(:patch_request) { patch "/providers/applications/#{application_id}/check_client_details" }

    before do
      login_as application.provider
      patch_request
    end

    it "continues to the received benefit confirmations page" do
      expect(response).to redirect_to(providers_legal_aid_application_received_benefit_confirmation_path(application))
    end
  end
end
