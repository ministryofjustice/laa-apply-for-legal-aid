require "rails_helper"

RSpec.describe Flow::Steps::CitizenStart::ConsentsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application, open_banking_consent:) }
  let(:open_banking_consent) { true }

  describe "#path" do
    subject(:path) { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql citizens_consent_path(locale: I18n.locale) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    context "when the citizen consents to open banking" do
      it { is_expected.to eq :banks }
    end

    context "when the citizen does not consent to open banking" do
      let(:open_banking_consent) { false }

      it { is_expected.to eq :contact_providers }
    end
  end
end
