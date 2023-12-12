require "rails_helper"

RSpec.describe Address do
  subject(:model) { build(:address) }

  it "is valid with all valid attributes" do
    expect(model).to be_valid
  end

  it "is not valid without a building name and street address" do
    model.address_line_one = ""
    model.address_line_two = ""
    expect(model).not_to be_valid
    expect(model.errors[:address_line_one]).to include("can't be blank")
  end

  it "is valid without a building name" do
    model.address_line_one = ""
    expect(model).to be_valid
  end

  it "is valid without a street address" do
    model.address_line_two = ""
    expect(model).to be_valid
  end

  it "is not valid without a town or city" do
    model.city = nil
    expect(model).not_to be_valid
    expect(model.errors[:city]).to include("can't be blank")
  end

  it "is not valid when a postcode is not provided" do
    model.postcode = nil
    expect(model).not_to be_valid
    expect(model.errors[:postcode]).to include("can't be blank")
  end

  it "is not valid if the postcode entered is not in the correct format" do
    model.postcode = "1GIR00A"
    expect(model).not_to be_valid
    expect(model.errors[:postcode]).to include("is not in the right format")
  end

  it "can display the postcode with a space reinserted" do
    model.postcode = "SW1H9AJ"
    expect(model.pretty_postcode).to eq("SW1H 9AJ")
  end
end
