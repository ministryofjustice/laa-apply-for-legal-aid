require 'rails_helper'

RSpec.describe Address, type: :model do
  subject { build(:address) }

  it 'is valid with all valid attributes' do
    expect(subject).to be_valid
  end

  it 'is not valid without a building name and street address' do
    subject.address_line_one = ''
    subject.address_line_two = ''
    expect(subject).to_not be_valid
    expect(subject.errors[:address_line_one]).to include("can't be blank")
  end

  it 'is valid without a building name' do
    subject.address_line_one = ''
    expect(subject).to be_valid
  end

  it 'is valid without a street address' do
    subject.address_line_two = ''
    expect(subject).to be_valid
  end

  it 'is not valid without a town or city' do
    subject.city = nil
    expect(subject).to_not be_valid
    expect(subject.errors[:city]).to include("can't be blank")
  end

  it 'is not valid when a postcode is not provided' do
    subject.postcode = nil
    expect(subject).to_not be_valid
    expect(subject.errors[:postcode]).to include("can't be blank")
  end

  it 'is not valid if the postcode entered is not in the correct format' do
    subject.postcode = '1GIR00A'
    expect(subject).to_not be_valid
    expect(subject.errors[:postcode]).to include('is not in the right format')
  end

  it 'can display the postcode with a space reinserted' do
    subject.postcode = 'SW1H9AJ'
    expect(subject.pretty_postcode).to eq('SW1H 9AJ')
  end
end
