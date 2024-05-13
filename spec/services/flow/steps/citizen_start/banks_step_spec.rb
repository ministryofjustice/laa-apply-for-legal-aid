require "rails_helper"

RSpec.describe Flow::Steps::CitizenStart::BanksStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject(:path) { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql citizens_banks_path(locale: I18n.locale) }
  end

  describe "#forward" do
    subject { described_class.forward }

    it { is_expected.to eq :true_layer }
  end
end
