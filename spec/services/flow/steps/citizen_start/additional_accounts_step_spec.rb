require "rails_helper"

RSpec.describe Flow::Steps::CitizenStart::AdditionalAccountsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application, has_offline_accounts:) }
  let(:has_offline_accounts) { true }

  describe "#path" do
    subject(:path) { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql citizens_additional_accounts_path(locale: I18n.locale) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    context "when the citizen has offline accounts" do
      it { is_expected.to eq :contact_providers }
    end

    context "when the citizen does not have offline accounts" do
      let(:has_offline_accounts) { false }

      it { is_expected.to eq :check_answers }
    end
  end
end
