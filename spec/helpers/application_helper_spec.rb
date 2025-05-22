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
        user_header_navigation(header)
        expect(header.navigation_items).to eq []
      end
    end

    context "when called on provider journey" do
      let(:journey_type) { :providers }

      context "when provider is signed in" do
        it "returns a link to edit provider details and a logout link" do
          user_header_navigation(header)
          expect(header.navigation_items.map(&:text)).to eq ["Test User", "Sign out"]
        end
      end

      context "when provider is not signed in" do
        let(:signed_in) { false }

        it "returns a login link" do
          user_header_navigation(header)
          expect(header.navigation_items.map(&:text)).to eq ["Sign In"]
        end
      end
    end

    context "when called on admin journey" do
      let(:journey_type) { :admin }

      context "when admin is signed in" do
        it "returns a logout link" do
          user_header_navigation(header)
          expect(header.navigation_items.map(&:text)).to eq ["Admin sign out"]
        end
      end

      context "when admin is not signed in" do
        let(:signed_in) { false }

        it "returns a login link" do
          user_header_navigation(header)
          expect(header.navigation_items.map(&:text)).to eq []
        end
      end
    end
  end
end
