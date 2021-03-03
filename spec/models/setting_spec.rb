require 'rails_helper'

RSpec.describe Setting do
  describe '.setting' do
    context 'when there is no setting record' do
      before { Setting.delete_all }

      it 'generates one with the default values' do
        rec = Setting.setting
        expect(rec.mock_true_layer_data?).to be false
        expect(rec.manually_review_all_cases?).to be true
        expect(rec.allow_welsh_translation?).to be false
        expect(rec.allow_multiple_proceedings?).to be false
        expect(rec.override_dwp_results?).to be false
        expect(rec.bank_transaction_filename).to eq 'db/sample_data/bank_transactions.csv'
      end
    end

    context 'when a record already exists with non-default values' do
      before do
        Setting.setting.update!(
          mock_true_layer_data: true,
          manually_review_all_cases: false,
          allow_welsh_translation: false,
          allow_multiple_proceedings: false,
          override_dwp_results: false,
          bank_transaction_filename: 'my_special_file.csv'
        )
      end

      it 'returns the existing record' do
        rec = Setting.setting
        expect(rec.mock_true_layer_data?).to be true
        expect(rec.manually_review_all_cases?).to be false
        expect(rec.allow_welsh_translation?).to be false
        expect(rec.allow_multiple_proceedings?).to be false
        expect(rec.override_dwp_results?).to be false
        expect(rec.bank_transaction_filename).to eq 'my_special_file.csv'
      end
    end
  end

  describe 'class methods' do
    before { Setting.destroy_all }

    it 'returns the value with a class method' do
      expect(Setting.mock_true_layer_data?).to be false
      expect(Setting.manually_review_all_cases?).to be true
      expect(Setting.allow_welsh_translation?).to be false
      expect(Setting.allow_multiple_proceedings?).to be false
      expect(Setting.override_dwp_results?).to be false
      expect(Setting.bank_transaction_filename).to eq 'db/sample_data/bank_transactions.csv'
    end
  end
end
