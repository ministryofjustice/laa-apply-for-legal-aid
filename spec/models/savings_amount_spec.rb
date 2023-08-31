require "rails_helper"

RSpec.describe SavingsAmount do
  describe "#positive" do
    subject(:savings_amount) { create(:savings_amount) }

    context "with no savings" do
      it "is negative" do
        expect(savings_amount.positive?).to be(false)
      end
    end

    context "with some savings" do
      before { savings_amount.update!(cash: rand(1...1_000_000.0).round(2)) }

      it "is positive" do
        expect(savings_amount.positive?).to be(true)
      end
    end
  end

  describe "#values?" do
    subject(:savings_amount) { create(:savings_amount, :with_values) }

    context "with savings and investments" do
      it "returns true" do
        expect(savings_amount.values?).to be true
      end
    end

    context "when it has a single value, set to 0" do
      subject(:savings_amount) { create(:savings_amount, offline_current_accounts: 0_0) }

      it "returns true" do
        expect(savings_amount.values?).to be true
      end
    end

    context "with no savings and investments" do
      subject(:savings_amount) { create(:savings_amount, :all_nil) }

      it "returns false" do
        expect(savings_amount.values?).to be false
      end
    end
  end
end
