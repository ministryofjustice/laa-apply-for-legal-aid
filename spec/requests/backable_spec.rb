require "rails_helper"

RSpec.describe "Backable", :vcr do
  let(:application) { create(:legal_aid_application, :with_applicant) }
  let(:address_lookup_path) { providers_legal_aid_application_correspondence_address_lookup_path(application) }
  let(:address_path) { providers_legal_aid_application_correspondence_address_manual_path(application) }
  let(:proceeding_type_path) { providers_legal_aid_application_proceedings_types_path(application) }
  let(:statement_of_case_upload_list_path) { list_providers_legal_aid_application_statement_of_case_upload_path(application) }
  let(:address_params) do
    {
      address:
      {
        address_line_one: "123",
        address_line_two: "High Street",
        city: "London",
        county: "Greater London",
        postcode: "SW1H 9AJ",
      },
    }
  end

  before { login_as application.provider }

  describe "back_path" do
    before do
      get address_lookup_path
      get address_path
      patch address_path, params: address_params
      get proceeding_type_path
    end

    it "has a back link to the previous page" do
      expect(response.body).to have_back_link("#{address_path}&back=true")
    end

    context "when we reload the current page several times" do
      before do
        get proceeding_type_path
        get proceeding_type_path
      end

      it "has a back link to the previous page" do
        expect(response.body).to have_back_link("#{address_path}&back=true")
      end
    end

    context "when we go back once" do
      it "redirects to same page without the param" do
        get "#{address_path}&back=true"
        expect(response).to redirect_to(address_path)
      end

      it "has a link to the previous page" do
        get "#{address_path}&back=true"
        get address_path
        expect(response.body).to have_back_link("#{address_lookup_path}&back=true")
      end
    end

    context "when we have uploaded a statement of case in the merits task list" do
      before do
        get statement_of_case_upload_list_path
        get proceeding_type_path
      end

      it "does not link to the list_statement_of_case_upload_list_path" do
        expect(response.body).to have_back_link("#{address_path}&back=true")
      end
    end
  end
end
