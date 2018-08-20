require 'rails_helper'
require 'date'

RSpec.describe Applicant, type: :model do
  subject { described_class.new }

  let!(:application) { LegalAidApplication.create }

  before do
    subject.name = "John Doe"
    subject.date_of_birth = Date.new(1988, 02, 01)
    subject.legal_aid_application_id = application.id
  end

  it "is valid with all valid attributes" do
    expect(subject).to be_valid
  end

  it "is not valid without a name" do
    subject.name = ""
    expect(subject).to_not be_valid
  end

  it "is not valid without a date of birth" do
    subject.date_of_birth = nil
    expect(subject).to_not be_valid
  end

  it "is not valid if the date of birth is in the future" do
    subject.date_of_birth = Date.today + 1
    expect(subject).to_not be_valid
  end

  it "is not valid if the date of birth is before 1900-01-01" do
    subject.date_of_birth = Date.new(1899, 12, 31)
    expect(subject).to_not be_valid
  end

  it "should belong to a legal aid application" do
    expect(subject.legal_aid_application_id).to eq(application.id)
  end

end
