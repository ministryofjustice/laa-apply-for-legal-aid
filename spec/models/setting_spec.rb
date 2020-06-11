require 'rails_helper'

RSpec.describe Setting do
  describe '.setting' do
    context 'when there is no setting record' do
      before { Setting.delete_all }

      it 'generates one with the default values' do
        rec = Setting.setting
        expect(rec.mock_true_layer_data?).to be false
        expect(rec.allow_non_passported_route?).to be true
        expect(rec.manually_review_all_cases?).to be true
        expect(rec.use_new_student_loan?).to be false
        expect(rec.bank_transaction_filename).to eq 'db/sample_data/bank_transactions.csv'
      end
    end

    context 'when a record already exists with non-default values' do
      before do
        Setting.setting.update!(
          mock_true_layer_data: true,
          allow_non_passported_route: false,
          manually_review_all_cases: false,
          use_new_student_loan: true,
          bank_transaction_filename: 'my_special_file.csv'
        )
      end

      it 'returns the existing record' do
        rec = Setting.setting
        expect(rec.mock_true_layer_data?).to be true
        expect(rec.allow_non_passported_route?).to be false
        expect(rec.manually_review_all_cases?).to be false
        expect(rec.use_new_student_loan?).to be true
        expect(rec.bank_transaction_filename).to eq 'my_special_file.csv'
      end
    end
  end

  describe 'class methods' do
    before { Setting.destroy_all }

    it 'returns the value with a class method' do
      expect(Setting.mock_true_layer_data?).to be false
      expect(Setting.allow_non_passported_route?).to be true
      expect(Setting.manually_review_all_cases?).to be true
      expect(Setting.use_new_student_loan?).to be false
      expect(Setting.bank_transaction_filename).to eq 'db/sample_data/bank_transactions.csv'
    end
  end
end
