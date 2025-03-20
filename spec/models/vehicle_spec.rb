require "rails_helper"

RSpec.describe Vehicle do
  describe "#purchased_on" do
    let(:vehicle) { create(:vehicle, more_than_three_years_old:) }

    describe "#complete?" do
      subject { vehicle.complete? }

      context "when all questions have been answered" do
        let(:vehicle) { create(:vehicle, estimated_value: 10_000, used_regularly: true, more_than_three_years_old: true) }

        it { is_expected.to be true }
      end

      context "when questions responses are partially complete" do
        let(:vehicle) { create(:vehicle, estimated_value: 10_000) }

        it { is_expected.to be false }
      end

      context "when questions responses are completely missing" do
        let(:vehicle) { create(:vehicle) }

        it { is_expected.to be false }
      end
    end

    context "when more than three years old" do
      let(:more_than_three_years_old) { true }

      it "returns a date 4 years ago" do
        expect(vehicle.cfe_civil_purchase_date).to eq 4.years.ago.to_date
      end
    end

    context "when less than three years old" do
      let(:more_than_three_years_old) { false }

      it "returns a date 2 years ago" do
        expect(vehicle.cfe_civil_purchase_date).to eq 2.years.ago.to_date
      end
    end
  end
end
