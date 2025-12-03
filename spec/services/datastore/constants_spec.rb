require "rails_helper"
RSpec.describe Datastore::Constants do
  describe ".status_value" do
    subject(:status_value) { described_class.status_value(key) }

    it "returns the expected value for :in_progress" do
      expect(described_class.status_value(:in_progress)).to eq("IN_PROGRESS")
    end

    it "returns the expected value for :submitted" do
      expect(described_class.status_value(:submitted)).to eq("SUBMITTED")
    end

    it "returns nil for :unknown" do
      expect(described_class.status_value(:unknown)).to be_nil
    end
  end

  describe ".status_label" do
    subject(:status_label) { described_class.status_label(key) }

    it "returns the expected label for :in_progress" do
      expect(described_class.status_label(:in_progress)).to eq("In progress")
    end

    it "returns the expected label for :submitted" do
      expect(described_class.status_label(:submitted)).to eq("Submitted")
    end

    it "returns nil for :unknown" do
      expect(described_class.status_label(:unknown)).to be_nil
    end
  end
end
