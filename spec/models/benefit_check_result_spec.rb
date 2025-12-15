require "rails_helper"

RSpec.describe BenefitCheckResult do
  describe "#positive?" do
    context "when result is 'Yes'" do
      subject(:instance) { described_class.new(result: "Yes") }

      it "returns true" do
        expect(instance.positive?).to be true
      end
    end

    context "when result is 'yES'" do
      subject(:instance) { described_class.new(result: "yES") }

      it "returns true" do
        expect(instance.positive?).to be true
      end
    end

    context "when result is 'No'" do
      subject(:instance) { described_class.new(result: "no") }

      it "returns true" do
        expect(instance.positive?).to be false
      end
    end

    context "when result is 'failure'" do
      subject(:instance) { described_class.new(result: "failure:blah") }

      it "returns true" do
        expect(instance.positive?).to be false
      end
    end
  end

  describe "#failure?" do
    context "when result starts with 'failure:'" do
      subject(:instance) { described_class.new(result: "failure:no_response") }

      it "returns true" do
        expect(instance.failure?).to be true
      end
    end

    context "when result is 'Yes'" do
      subject(:instance) { described_class.new(result: "Yes") }

      it "returns false" do
        expect(instance.failure?).to be false
      end
    end

    context "when result is 'No'" do
      subject(:instance) { described_class.new(result: "No") }

      it "returns false" do
        expect(instance.failure?).to be false
      end
    end
  end
end
