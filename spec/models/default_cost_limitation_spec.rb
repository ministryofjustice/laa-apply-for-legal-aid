require 'rails_helper'

RSpec.describe DefaultCostLimitation do
  let!(:legal_aid_application) do
    create :legal_aid_application,
           :with_applicant,
           :with_proceedings,
           set_lead_proceeding: :da001
  end
  let(:pt) { legal_aid_application.proceedings.find_by(ccms_code: 'DA001') }
  let!(:chances_of_success) do
    create :chances_of_success, :with_optional_text, proceeding: pt
  end

  context 'enum' do
    it 'does not allow invalid cost types' do
      expect {
        DefaultCostLimitation.create!(proceeding_type: pt, cost_type: 'xxxx', start_date: 1.month.ago, value: 55)
      }.to raise_error ArgumentError, "'xxxx' is not a valid cost_type"
    end
  end

  describe 'for_date' do
    let(:old_start_date) { Date.parse('1970-01-01') }
    let(:new_start_date) { Date.parse('2021-09-13') }

    before { pt }

    context 'before change date' do
      let(:date) { Date.parse('2021-09-12') }
      it 'returns the old value' do
        dcl = DefaultCostLimitation.delegated_functions.for_date(date)
        expect(dcl.value).to eq 1350
      end
    end

    context 'on change date' do
      let(:date) { Date.parse('2021-09-13') }
      it 'returns the old value' do
        dcl = DefaultCostLimitation.delegated_functions.for_date(date)
        expect(dcl.value).to eq 2250
      end
    end

    context 'on change date' do
      let(:date) { Date.parse('2021-09-19') }
      it 'returns the old value' do
        dcl = DefaultCostLimitation.delegated_functions.for_date(date)
        expect(dcl.value).to eq 2250
      end
    end
  end
end
