require "rails_helper"

RSpec.describe Flow::Steps::CitizenStart::GatherTransactionsStep, type: :request do
  describe "#forward" do
    subject { described_class.forward }

    it { is_expected.to eq :accounts }
  end
end
