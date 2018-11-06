# frozen_string_literal: true

class AddDeviseToApplicants < ActiveRecord::Migration[5.2]
  def change
    change_table :applicants do |t|
      ## Database authenticatable
      t.rename :email_address, :email

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at
    end

    add_index :applicants, :email,                unique: true
    add_index :applicants, :confirmation_token,   unique: true
    add_index :applicants, :unlock_token,         unique: true
  end
end
