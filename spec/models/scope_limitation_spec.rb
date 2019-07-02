require 'rails_helper'

RSpec.describe ScopeLimitation, type: :model do
  describe 'validation' do
    subject { described_class.new }

    before do
      subject.code = 'AA001'
      subject.meaning = 'test_limitation'
      subject.description = 'this is a test limitation'
      subject.substantive = true
      subject.delegated_functions = false
    end

    it 'is valid with all valid attributes' do
      expect(subject).to be_valid
    end

    it 'is invalid without a code' do
      subject.code = nil
      expect(subject).not_to be_valid
    end

    it 'is invalid without a meaning' do
      subject.meaning = nil
      expect(subject).not_to be_valid
    end

    it 'is invalid without a description' do
      subject.description = nil
      expect(subject).not_to be_valid
    end

    it 'is invalid without a substantive flag' do
      subject.substantive = nil
      expect(subject).not_to be_valid
    end

    it 'is invalid without a delegated_functions flag' do
      subject.delegated_functions = nil
      expect(subject).not_to be_valid
    end
  end
end
