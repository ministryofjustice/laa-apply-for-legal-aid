require "rails_helper"

RSpec.describe LinkedApplicationType do
  describe ".all" do
    it "returns a collection of Link types" do
      described_class.all.each do |link_type|
        expect(link_type.respond_to?(:code)).to be true
        expect(link_type.respond_to?(:description)).to be true
      end
    end

    it "returns expected collection attribute values" do
      expect(described_class.all.map(&:description)).to match_array %w[Family Legal]
      expect(described_class.all.map(&:code)).to match_array %w[FAMILY LEGAL]
    end
  end
end
