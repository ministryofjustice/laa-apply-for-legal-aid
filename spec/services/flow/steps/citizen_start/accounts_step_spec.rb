require "rails_helper"

RSpec.describe Flow::Steps::CitizenStart::AccountsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject(:path) { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql citizens_accounts_path(locale: I18n.locale) }
  end

  describe "#forward" do
    subject { described_class.forward }

    it { is_expected.to eq :additional_accounts }
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    it { is_expected.to eq :check_answers }
  end
end
