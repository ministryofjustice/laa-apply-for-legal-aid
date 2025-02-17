require "rails_helper"

RSpec.describe CapitalHelper do
  describe ".capital_amount_text" do
    subject(:capital_amount_text) { helper.capital_amount_text(amount, type) }

    let(:amount) { nil }
    let(:type) { nil }

    context "when amount is nil" do
      it { is_expected.to eq "No" }
    end

    context "when type is a percentage" do
      let(:amount) { 12.34 }
      let(:type) { :percentage }

      it { is_expected.to eq "12.34%" }
    end

    context "when is not nil and not a percentage" do
      let(:amount) { 12.34 }

      it { is_expected.to eq "£12.34" }
    end
  end
end
