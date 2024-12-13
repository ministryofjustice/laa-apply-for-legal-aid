require "rails_helper"

RSpec.describe SubstantiveApplicationDeadlineCalculator, :vcr do
  describe ".call" do
    subject(:call) { described_class.call(df_date) }

    context "when passed the regular 4 weeks" do
      let(:df_date) { Date.new(2021, 2, 26) }

      it "returns a date 20 working days after" do
        expect(call).to eq Date.new(2021, 3, 26)
      end
    end

    context "with bank holidays" do
      let(:df_date) { Date.new(2020, 12, 15) }

      it "returns a date taking bank holidays into account" do
        expect(call).to eq Date.new(2021, 1, 15)
      end
    end
  end
end
