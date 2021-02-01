class CreateSentEmails < ActiveRecord::Migration[6.1]
  def change
    create_table :sent_emails, id: :uuid do |t|
      t.string :mailer
      t.string :mail_method
      t.string :addressee
      t.string :govuk_message_id
      t.string :mailer_args
      t.datetime :sent_at
      t.string :status
      t.datetime :status_checked_at

      t.timestamps
    end

    add_index :sent_emails, :govuk_message_id, unique: true
  end
end
