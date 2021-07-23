class AddEnableCCMSSubmissionToSetting < ActiveRecord::Migration[6.1]
  def change
    add_column :settings, :enable_ccms_submission, :boolean, default: true, null: false
  end
end
