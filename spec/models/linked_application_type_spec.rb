require "rails_helper"

RSpec.describe LinkedApplicationType do
  describe ".all" do
    subject(:all_method) { described_class.all }

    it "returns a collection of Link type objects" do
      expect(all_method).to all(respond_to(:code, :description))
    end

    it "returns expected collection attribute values" do
      expect(all_method.map(&:description)).to match_array %w[Family Legal]
      expect(all_method.map(&:code)).to match_array %w[FC_LEAD LEGAL]
    end
  end
end
