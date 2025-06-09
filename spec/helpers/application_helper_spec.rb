require "rails_helper"

RSpec.describe ApplicationHelper do
  helper do
    def provider_signed_in?
      signed_in
    end

    def admin_user_signed_in?
      signed_in
    end

    def current_provider
      provider
    end

    def current_journey
      journey_type
    end
  end

  let(:header) { GovukComponent::HeaderComponent.new }
  let(:signed_in) { true }
  let(:journey_type) { :citizens }
  let(:provider) { create(:provider, username: "Test User") }

  describe "#user_header_navigation" do
    context "when called on citizens journey" do
      it "returns no navigation items" do
        expect(user_header_navigation).to be_nil
      end
    end

    context "when called on provider journey" do
      let(:journey_type) { :providers }

      context "when provider is signed in" do
        it "returns a link to edit provider details and a logout link" do
          expect(user_header_navigation).to have_css("li", count: 2)
            .and have_css("li", text: "Test User")
            .and have_css("li", text: "Sign out")
        end
      end

      context "when provider is not signed in" do
        let(:signed_in) { false }

        it "returns a login link" do
          expect(user_header_navigation).to have_css("li", count: 1)
            .and have_css("li", text: "Sign In")
        end
      end
    end

    context "when called on admin journey" do
      let(:journey_type) { :admin }

      context "when admin is signed in" do
        it "returns a logout link" do
          expect(user_header_navigation).to have_css("li", count: 1)
            .and have_css("li", text: "Admin sign out")
        end
      end

      context "when admin is not signed in" do
        let(:signed_in) { false }

        it "returns a login link" do
          expect(user_header_navigation).to be_nil
        end
      end
    end
  end
end
