class CreateScheduledMailings < ActiveRecord::Migration[5.2]
  def change
    create_table :scheduled_mailings, id: :uuid do |t|
      t.uuid :legal_aid_application_id, null: false
      t.string :mailer_klass, null: false
      t.string :mailer_method, null: false
      t.string :arguments, null: false
      t.datetime :scheduled_at, null: false
      t.datetime :sent_at, default: nil
      t.datetime :cancelled_at, default: nil

      t.timestamps
    end
  end
end
