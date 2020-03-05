class AddForeignKeyToScheduledMailings < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :scheduled_mailings, :legal_aid_applications, on_delete: :cascade
  end
end
