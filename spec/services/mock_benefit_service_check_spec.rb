require 'rails_helper'

RSpec.describe MockBenefitCheckService do
  let(:last_name) { 'Smith' }
  let(:date_of_birth) { '1999/01/11'.to_date }
  let(:national_insurance_number) { 'ZZ123459A' }
  let(:applicant) { create :applicant, last_name: last_name, date_of_birth: date_of_birth, national_insurance_number: national_insurance_number }
  let(:application) { create :application, applicant: applicant }

  subject { described_class.call(application) }

  describe '.call' do
    it 'returns confirmation_ref' do
      expect(subject[:confirmation_ref]).to eq("mocked:#{described_class}")
    end

    it "returns 'Yes' as in known data" do
      expect(subject[:benefit_checker_status]).to eq('Yes')
    end

    context 'with incorrect date' do
      let(:date_of_birth) { '2012/01/10'.to_date }

      it 'returns no' do
        expect(subject[:benefit_checker_status]).to eq('No')
      end

      it 'returns confirmation_ref' do
        expect(subject[:confirmation_ref]).to eq("mocked:#{described_class}")
      end
    end

    context 'with unknown name' do
      let(:last_name) { 'Unknown' }

      it 'returns no' do
        expect(subject[:benefit_checker_status]).to eq('No')
      end
    end
  end
end
