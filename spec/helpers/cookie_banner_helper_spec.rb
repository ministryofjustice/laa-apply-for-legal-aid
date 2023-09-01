require "rails_helper"

RSpec.describe CookieBannerHelper do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:provider) { legal_aid_application.provider }

  describe "#display_cookie_banner?" do
    subject(:display_cookie_banner) { display_cookie_banner?(provider) }

    context "when the provider's cookie preferences have expired" do
      let(:provider) { create(:provider, cookies_enabled: true, cookies_saved_at: 1.year.ago - 1.day) }

      it "displays the cookie banner" do
        expect(display_cookie_banner).to be true
      end
    end

    context "when the provider's cookie preferences have not expired" do
      let(:provider) { create(:provider, cookies_enabled: true, cookies_saved_at: 1.year.ago + 1.day) }

      it "does not display the cookie banner" do
        expect(display_cookie_banner).to be false
      end
    end

    context "when the provider has not chosen their cookie preferences" do
      let(:provider) { create(:provider, cookies_enabled: nil, cookies_saved_at: nil) }

      it "displays the cookie banner" do
        expect(display_cookie_banner).to be true
      end
    end

    context "when the provider has chosen their cookie preferences but there is no timestamp" do
      let(:provider) { create(:provider, cookies_enabled: true, cookies_saved_at: nil) }

      it "displays the cookie banner" do
        expect(display_cookie_banner).to be true
      end
    end
  end
end
