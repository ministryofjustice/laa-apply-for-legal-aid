require 'rails_helper'

RSpec.describe Applicant, type: :model do
  subject { described_class.new }

  before do
    subject.first_name = 'John'
    subject.last_name = 'Doe'
    subject.date_of_birth = Date.new(1988, 0o2, 0o1)
  end

  it 'is valid with all valid attributes' do
    expect(subject).to be_valid
  end

  it 'is not valid without a first name' do
    subject.first_name = ''
    expect(subject).to_not be_valid
    expect(subject.errors[:first_name]).to include("can't be blank")
  end

  it 'is not valid without a last name' do
    subject.last_name = ''
    expect(subject).to_not be_valid
    expect(subject.errors[:last_name]).to include("can't be blank")
  end

  it 'is not valid without a date of birth' do
    subject.date_of_birth = nil
    expect(subject).to_not be_valid
    expect(subject.errors[:date_of_birth]).to include("can't be blank")
  end

  it 'is not valid if the date of birth is in the future' do
    subject.date_of_birth = Date.today + 1
    expect(subject).to_not be_valid
  end

  it 'is not valid if the date of birth is before 1900-01-01' do
    subject.date_of_birth = Date.new(1899, 12, 31)
    expect(subject).to_not be_valid
  end
end
