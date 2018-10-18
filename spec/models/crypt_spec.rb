require 'rails_helper'

RSpec.describe Crypt, type: :model do
  let(:crypt) { described_class.new }
  let(:text) { Faker::Lorem.sentence }

  describe '#encrypt' do
    let(:result) { crypt.encrypt(text) }

    it 'does not return input' do
      expect(result).not_to eq(text)
    end

    it 'creates a long string' do
      expect(result.length).to be > 20
    end

    it 'creates a URL safe string' do
      expect(result).not_to match('=')
    end
  end

  describe '#decrypt' do
    let(:token) { crypt.encrypt(text) }
    let(:result) { crypt.decrypt(token) }

    it 'should return text' do
      expect(result).to eq(text)
    end
  end
end
