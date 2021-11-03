class CreateApplicationDigestTable < ActiveRecord::Migration[6.1]
  def change
    create_table :application_digests, id: :uuid do |t|
      t.uuid :legal_aid_application_id, null: false
      t.string :firm_name, null: false
      t.string :provider_username, null: false
      t.date :date_started, null: false
      t.date :date_submitted, default: nil
      t.integer :days_to_submission, default: nil
      t.boolean :use_ccms, default: false
      t.string :matter_types, null: false
      t.string :proceedings, null: false
      t.boolean :passported, default: false
      t.boolean :df_used, default: false
      t.date :earliest_df_date, default: nil
      t.date :df_reported_date, default: nil
      t.integer :working_days_to_report_df, default: nil
      t.integer :working_days_to_submit_df, default: nil

      t.timestamps
    end

    add_index :application_digests, :legal_aid_application_id, unique: true
  end
end
