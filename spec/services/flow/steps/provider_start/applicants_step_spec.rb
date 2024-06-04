require "rails_helper"

RSpec.describe Flow::Steps::ProviderStart::ApplicantsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq new_providers_applicant_path }
  end

  describe "#forward" do
    subject { described_class.forward.call(nil) }

    before { allow(Setting).to receive(:home_address?).and_return(home_address_setting) }

    let(:home_address_setting) { false }

    context "when the home_address feature flag is enabled" do
      let(:home_address_setting) { true }

      it { is_expected.to eq :correspondence_address_choices }
    end

    it { is_expected.to eq :correspondence_address_lookups }
  end
end
