require "rails_helper"

RSpec.describe Address do
  subject(:model) { build(:address) }

  describe ".pretty_postcode" do
    it "can display the postcode with a space reinserted" do
      model.postcode = "SW1H9AJ"
      expect(model.pretty_postcode).to eq("SW1H 9AJ")
    end

    it "returns nil if the postcode is nil" do
      model.postcode = nil
      expect(model.pretty_postcode).to be_nil
    end
  end

  describe ".save" do
    it "converts the postcode to uppercase and deletes whitespace" do
      model.postcode = "sw1h 9aj"
      model.save!
      expect(model.postcode).to eq("SW1H9AJ")
    end
  end
end
