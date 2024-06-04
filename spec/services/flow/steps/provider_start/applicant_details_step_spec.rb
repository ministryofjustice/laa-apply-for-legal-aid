require "rails_helper"

RSpec.describe Flow::Steps::ProviderStart::ApplicantDetailsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_applicant_details_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    context "when not overriding dwp result" do
      it { is_expected.to eq :correspondence_address_lookups }
    end

    context "when overriding dwp result" do
      let(:legal_aid_application) { create(:legal_aid_application, :overriding_dwp_result) }

      it { is_expected.to eq :has_national_insurance_numbers }
    end

    context "when the home_address feature flag is enabled" do
      before { allow(Setting).to receive(:home_address?).and_return(true) }

      it { is_expected.to eq :correspondence_address_choices }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    it { is_expected.to eq :check_provider_answers }
  end
end
