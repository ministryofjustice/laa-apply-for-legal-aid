require 'rails_helper'

RSpec.describe Applicant, type: :model do
  subject { described_class.new }

  before do
    subject.first_name = 'John'
    subject.last_name = 'Doe'
    subject.date_of_birth = Date.new(1988, 0o2, 0o1)
    subject.national_insurance_number = 'AB123456D'
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

  it 'is not valid if the email entered is not in the correct form' do
    subject.email = 'asdfgh'
    expect(subject).to_not be_valid
    expect(subject.errors[:email]).to include('address is not in the right format')
  end

  it 'is valid when the email address provided is in the correct format' do
    subject.email = 'test@test.com'
    expect(subject).to be_valid
  end

  it 'is valid when email address is not provided' do
    subject.email = nil
    expect(subject).to be_valid
  end

  it 'is not valid when a national insurance number is not provided' do
    subject.national_insurance_number = nil
    expect(subject).to_not be_valid
    expect(subject.errors[:national_insurance_number]).to include("can't be blank")
  end

  it 'is not valid if the national insurance number entered is not in the correct form' do
    subject.national_insurance_number = 'QQ12AS23RR'
    expect(subject).to_not be_valid
    expect(subject.errors[:national_insurance_number]).to include('is not in the right format')
  end
end
