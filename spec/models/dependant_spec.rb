require "rails_helper"

RSpec.describe Dependant do
  let(:calculation_date) { Date.current }
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, transaction_period_finish_on: calculation_date) }
  let(:dependant) { create(:dependant, legal_aid_application:, date_of_birth:) }

  describe "#ordinal_number" do
    it "returns the correct ordinal_number" do
      expect(described_class.new(number: 1).ordinal_number).to eq("first")
      expect(described_class.new(number: 5).ordinal_number).to eq("fifth")
      expect(described_class.new(number: 9).ordinal_number).to eq("ninth")
      expect(described_class.new(number: 10).ordinal_number).to eq("10th")
    end
  end

  describe "#as_json" do
    context "when dependant has nil values" do
      let(:dependant) do
        create(:dependant,
               date_of_birth: Date.new(2019, 3, 2),
               in_full_time_education: nil,
               has_assets_more_than_threshold: nil,
               has_income: nil,
               relationship: nil,
               monthly_income: nil,
               assets_value: nil)
      end
      let(:expected_hash) do
        {
          date_of_birth: "2019-03-02",
          in_full_time_education: false,
          relationship: "child_relative",
          monthly_income: 0.0,
          assets_value: 0.0,
        }
      end

      it "returns the expected hash" do
        expect(dependant.as_json).to eq expected_hash
      end
    end

    context "when dependant has values" do
      let(:dependant) do
        create(:dependant,
               date_of_birth: Date.new(2019, 3, 2),
               in_full_time_education: true,
               has_assets_more_than_threshold: false,
               has_income: true,
               relationship: "adult_relative",
               monthly_income: 123.45,
               assets_value: 6789.0)
      end
      let(:expected_hash) do
        {
          date_of_birth: "2019-03-02",
          in_full_time_education: true,
          relationship: "adult_relative",
          monthly_income: 123.45,
          assets_value: 6789.0,
        }
      end

      it "returns the expected hash" do
        expect(dependant.as_json).to eq expected_hash
      end
    end
  end

  describe "#over_fifteen?" do
    context "when 10 years old" do
      let(:date_of_birth) { 10.years.ago }

      it "over_fifteen? returns false" do
        expect(dependant.over_fifteen?).to be(false)
      end

      it "sixteen_or_over? returns false" do
        expect(dependant.sixteen_or_over?).to be(false)
      end
    end

    context "when more than 20 years old" do
      let(:date_of_birth) { 20.years.ago }

      it "over_fifteen? returns true" do
        expect(dependant.over_fifteen?).to be(true)
      end

      it "sixteen_or_over? returns true" do
        expect(dependant.sixteen_or_over?).to be(true)
      end
    end

    context "when 15 and a half years old" do
      let(:date_of_birth) { 15.years.ago + 6.months }

      it "over_fifteen? returns false" do
        expect(dependant.over_fifteen?).to be(false)
      end

      it "sixteen_or_over? returns false" do
        expect(dependant.sixteen_or_over?).to be(false)
      end
    end

    context "when 14 and a half years old" do
      let(:date_of_birth) { 15.years.ago - 6.months }

      it "returns false" do
        expect(dependant.over_fifteen?).to be(false)
      end
    end
  end

  describe "#eighteen_or_less?" do
    context "when less than 18 years old" do
      let(:date_of_birth) { 10.years.ago }

      it "returns true" do
        expect(dependant.eighteen_or_less?).to be(true)
      end
    end

    context "when more than 18 years old" do
      let(:date_of_birth) { 20.years.ago }

      it "returns false" do
        expect(dependant.eighteen_or_less?).to be(false)
      end
    end

    context "when 18 and a half years old" do
      let(:date_of_birth) { 18.years.ago + 6.months }

      it "returns true" do
        expect(dependant.eighteen_or_less?).to be(true)
      end
    end

    context "when 17 and a half years old" do
      let(:date_of_birth) { 18.years.ago - 6.months }

      it "returns true" do
        expect(dependant.eighteen_or_less?).to be(true)
      end
    end
  end

  describe "ccms_relationship_to_client" do
    let(:dependant) { create(:dependant, legal_aid_application:, relationship:, date_of_birth: dob) }

    context "when adult relative" do
      let(:relationship) { "adult_relative" }
      let(:dob) { 20.years.ago }

      it "returns adult relative" do
        expect(dependant.ccms_relationship_to_client).to eq "Dependent adult"
      end
    end

    context "when child aged fifteen or less" do
      let(:relationship) { "child_relative" }
      let(:dob) { 13.years.ago }

      it "returns adult relative" do
        expect(dependant.ccms_relationship_to_client).to eq "Child aged 15 and under"
      end
    end

    context "when child aged sixteen or more" do
      let(:relationship) { "child_relative" }
      let(:dob) { 17.years.ago }

      it "returns adult relative" do
        expect(dependant.ccms_relationship_to_client).to eq "Child aged 16 and over"
      end
    end
  end

  describe "assets_over_threshold?" do
    subject(:assets_over_threshold) { dependant.assets_over_threshold? }

    let(:dependant) { create(:dependant, legal_aid_application:, assets_value:) }

    context "when assets_value is nil" do
      let(:assets_value) { nil }

      it { is_expected.to be false }
    end

    context "when assets_value is below threshold" do
      let(:assets_value) { 7999.99 }

      it { is_expected.to be false }
    end

    context "when assets_value is on threshold" do
      let(:assets_value) { 8000 }

      it { is_expected.to be false }
    end

    context "when assets_value is above threshold" do
      let(:assets_value) { 8000.01 }

      it { is_expected.to be true }
    end
  end
end
