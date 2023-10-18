require "rails_helper"

RSpec.describe LinkedApplicationType do
  describe ".link_types" do
    it "returns link types" do
      expect(described_class.all.map(&:description)).to match_array %w[Family Legal]
      expect(described_class.all.map(&:code)).to match_array %w[FAMILY LEGAL]
    end
  end
end
