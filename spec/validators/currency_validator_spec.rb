require 'rails_helper'

class DummyClass
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :val1, :val2, :val3

  validates :val1, :val2, :val3, currency: { greater_than_or_equal_to: 0 }, allow_blank: true
end

RSpec.describe CurrencyValidator do
  describe 'numericality validation' do
    let(:dummy) { DummyClass.new }

    it 'raises not numeric errors on each invalid field' do
      dummy.val1 = 'abc'
      dummy.val2 = 'qwe'
      expect(dummy).to be_invalid
      expect(dummy.errors[:val1]).to eq ['is not a number']
      expect(dummy.errors[:val2]).to eq ['is not a number']
      expect(dummy.errors[:val3]).to be_empty
    end

    it 'errors if given negative number' do
      dummy.val1 = Faker::Number.between(from: -9999, to: -1).to_s
      dummy.val2 = Faker::Number.number.to_s
      expect(dummy).to be_invalid
      expect(dummy.errors[:val1]).to eq ['must be greater than or equal to 0']
      expect(dummy.errors[:val2]).to be_empty
      expect(dummy.errors[:val3]).to be_empty
    end

    it 'validates ok with £ and commas' do
      dummy.val1 = '-1,234'
      dummy.val2 = '£1,234.88'
      expect(dummy).to be_invalid
      expect(dummy.errors[:val1]).to eq ['must be greater than or equal to 0']
      expect(dummy.errors[:val2]).to be_empty
      expect(dummy.errors[:val3]).to be_empty
    end

    it 'does not clean the number if invalid' do
      dummy.val1 = '-1,234'
      dummy.val2 = '-£1,234.88'
      expect(dummy).to be_invalid
      expect(dummy.val1).to eq '-1,234'
      expect(dummy.val2).to eq '-£1,234.88'
    end

    it 'fails if there are too many decimals' do
      dummy.val1 = '1,234.123'
      dummy.val2 = '£1,234.8888'
      expect(dummy).to be_invalid
      expect(dummy.errors.details[:val1].first[:error]).to eq :too_many_decimals
      expect(dummy.errors.details[:val2].first[:error]).to eq :too_many_decimals
      expect(dummy.errors[:val3]).to be_empty
      expect(dummy.val1).to eq '1,234.123'
      expect(dummy.val2).to eq '£1,234.8888'
    end

    it 'fails if comma is followed by less than 3 digits' do
      dummy.val1 = '1,23.00'
      dummy.val2 = '-£1,23'
      expect(dummy).to be_invalid
      expect(dummy.errors.details[:val1].first[:error]).to eq :not_a_number
      expect(dummy.errors.details[:val2].first[:error]).to eq :not_a_number
      expect(dummy.errors[:val3]).to be_empty
      expect(dummy.val1).to eq '1,23.00'
      expect(dummy.val2).to eq '-£1,23'
    end
  end
end
