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
            .and have_css("li", text: "My profile")
            .and have_css("li", text: "Sign out")
        end
      end

      context "when provider is not signed in" do
        let(:signed_in) { false }

        it "returns a login link" do
          expect(user_header_navigation).to have_css("li", count: 1)
            .and have_css("li", text: "Sign in")
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

  describe "#print_button" do
    let(:print_btn) { print_button(text, primary:) }

    let(:text) { "Print text" }
    let(:primary) { nil }

    context "when primary is not set" do
      it "outputs a secondary button" do
        expect(print_btn).to have_button(class: "govuk-button--secondary")
      end
    end

    context "when primary is true" do
      let(:primary) { true }

      it "outputs a primary button" do
        expect(print_btn).to have_button(class: "govuk-button--secondary")
      end
    end
  end

  describe "#phase_banner_tag" do
    subject(:banner) { phase_banner_tag }

    context "when on the develoment environment" do
      before do
        allow(HostEnv).to receive(:environment).and_return(:development)
      end

      it { is_expected.to eq({ text: "Development", colour: "green" }) }
    end

    context "when on the staging environment" do
      before do
        allow(HostEnv).to receive(:environment).and_return(:staging)
      end

      it { is_expected.to eq({ text: "Staging", colour: "orange" }) }
    end

    context "when on the UAT environment" do
      before do
        allow(HostEnv).to receive(:environment).and_return(:uat)
      end

      it { is_expected.to eq({ text: "UAT", colour: "purple" }) }
    end

    context "when on the production environment" do
      before do
        allow(HostEnv).to receive(:environment).and_return(:production)
      end

      it { is_expected.to eq({ text: "Beta" }) }
    end
  end
end
