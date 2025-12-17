require "system_helper"

RSpec.describe "End of application page" do
  before do
    login_as_a_provider

    visit providers_legal_aid_application_end_of_application_path(application)
  end

  context "when application has special children act proceedings" do
    let(:application) do
      create(:legal_aid_application,
             :with_proceedings,
             explicit_proceedings: [:pb003],
             provider: @registered_provider)
    end

    it "displays special children act message" do
      expect(page).to have_content("Keep a copy of the application for records, along with any evidence you included.")
                  .and have_no_content("Keep on file:")
    end
  end

  context "when application is non-means tested" do
    let(:application) do
      create(:legal_aid_application,
             :with_under_18_applicant,
             provider: @registered_provider)
    end

    it "displays under 18 message" do
      expect(page).to have_content("Print the completed application and get the person acting for #{application.applicant_full_name}")
                  .and have_content("Keep on file:")
    end
  end

  context "when applicant has partner with no contrary interest" do
    let(:application) do
      create(:legal_aid_application,
             :with_applicant_and_partner_with_no_contrary_interest,
             provider: @registered_provider)
    end

    it "displays partner message" do
      expect(page).to have_content("Print the completed application and get your client and their partner to sign it.")
                  .and have_content("Keep on file:")
    end
  end

  context "when applicant is over 18 without partner" do
    let(:application) do
      create(:legal_aid_application,
             :with_applicant_and_no_partner,
             provider: @registered_provider)
    end

    it "displays standard message" do
      expect(page).to have_content("Print the completed application and get your client to sign it.")
                  .and have_content("Keep on file:")
    end
  end
end
