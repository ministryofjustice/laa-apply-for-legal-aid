require 'rails_helper'

RSpec.describe IrregularIncome, type: :model do
  let(:application) { create :legal_aid_application }

  describe 'on validation' do
    subject { described_class.new }

    before do
      subject.legal_aid_application = application
      subject.income_type = 'student_loan'
      subject.frequency = 'annual'
    end

    it 'is valid with all valid attributes' do
      expect(subject).to be_valid
    end

    context 'invalid attributes' do
      before do
        subject.income_type = 'medical_loan'
        subject.frequency = 'annualzz'
      end

      it 'is invalid with any invalid attributes' do
        expect(subject).not_to be_valid
      end
    end
  end
end
