require 'rails_helper'

RSpec.describe ClientDetail, type: :model do
  subject { described_class.new }

  before do
    subject.name = "John Doe"
    subject.dob_day = "01"
    subject.dob_month = "02"
    subject.dob_year = "1988"
  end

  it "is valid with all valid attributes" do
    expect(subject).to be_valid
  end

  it "is not valid without a name" do
    subject.name = ""
    expect(subject).to_not be_valid
  end

  it "is not valid without a dob_day" do
    subject.dob_day = ""
    expect(subject).to_not be_valid
    print subject.errors.to_a
  end

  it "is not valid without a dob_month" do
    subject.dob_month = ""
    expect(subject).to_not be_valid
  end

  it "is not valid without a dob_year" do
    subject.dob_year = ""
    expect(subject).to_not be_valid
  end

end
