class AddNewStatusToScheduledMailings < ActiveRecord::Migration[6.1]
  def up
    change_column :scheduled_mailings, :legal_aid_application_id, :uuid, null: true
    add_column :scheduled_mailings, :status, :string
    add_column :scheduled_mailings, :addressee, :string
    add_column :scheduled_mailings, :govuk_message_id, :string

    execute "UPDATE scheduled_mailings SET status = 'delivered' WHERE sent_at IS NOT NULL"
    execute "UPDATE scheduled_mailings SET status = 'waiting' WHERE sent_at IS NULL"
  end

  def down
    remove_column :scheduled_mailings, :status
    remove_column :scheduled_mailings, :addressee
    remove_column :scheduled_mailings, :govuk_message_id
  end
end
