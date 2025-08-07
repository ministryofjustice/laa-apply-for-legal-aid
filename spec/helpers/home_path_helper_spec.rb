require "rails_helper"

RSpec.describe HomePathHelper do
  include YourApplicationsHelper

  describe "#home_path" do
    subject { home_path }

    context "when on provider journey" do
      context "and user has not reached the application page yet" do
        before do
          allow(request).to receive(:path).and_return(providers_select_office_path)
        end

        it { is_expected.to eq(root_path) }
      end

      context "and has gone past the application page" do
        let(:provider) { create(:provider) }

        before do
          allow(request).to receive(:path).and_return(providers_legal_aid_application_correspondence_address_choice_path(provider))
        end

        it { is_expected.to eq(in_progress_providers_legal_aid_applications_path) }
      end
    end

    context "when on citizens journey" do
      context "and test page is called" do
        before do
          allow(request).to receive(:path).and_return("/citizens/test")
        end

        it { is_expected.to eq(citizens_legal_aid_applications_path) }
      end
    end

    context "when on any other page" do
      before do
        allow(request).to receive(:path).and_return("/test")
      end

      it { is_expected.to eq(root_path) }
    end
  end
end
