require "rails_helper"

RSpec.describe TempContractData do
  subject(:record) { described_class.new(office_code:, response:) }

  let(:office_code) { "AB12345" }
  let(:response) do
    { test: "value" }
  end

  describe "validations" do
    context "when all variables set" do
      it { is_expected.to be_valid }
    end

    context "when the office_code is missing" do
      let(:office_code) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the response is missing" do
      let(:response) { nil }

      it { is_expected.to be_invalid }
    end
  end
end
