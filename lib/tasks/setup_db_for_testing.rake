namespace :settings do
  desc "Sets settings to values for integration testing"
  task integration: :environment do
    setting = Setting.setting
    setting.update!(mock_true_layer_data: true,
                    bank_transaction_filename: "db/sample_data/bank_transactions_2.csv",
                    manually_review_all_cases: false,
                    allow_welsh_translation: false,
                    enable_ccms_submission: true,
                    enable_employed_journey: false,
                    enable_evidence_upload: false,
                    enable_mini_loop: false,
                    enable_loop: false,
                    enhanced_bank_upload: false)

    pp Setting.first
  end
end
