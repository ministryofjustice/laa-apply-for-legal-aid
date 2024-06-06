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

  describe ".care_of_recipient" do
    context "when care of a person" do
      it "returns the name of the care of person" do
        model.care_of_first_name = "bob"
        model.care_of_last_name = "smith"
        model.care_of = "person"
        expect(model.care_of_recipient).to eq("bob smith")
      end
    end

    context "when care of an organisation" do
      it "returns the name of the care of organisation" do
        model.care_of_organisation_name = "an organisation"
        model.care_of = "organisation"
        expect(model.care_of_recipient).to eq("an organisation")
      end
    end

    context "when care of is nil" do
      it "returns nil" do
        expect(model.care_of_recipient).to be_nil
      end
    end
  end
end
