class CreateTrueLayerModels < ActiveRecord::Migration[5.2]
  def change
    create_table :bank_providers, id: :uuid do |t|
      t.belongs_to :applicant, foreign_key: true, null: false, type: :uuid
      t.json :true_layer_response
      t.string :credentials_id
      t.string :token
      t.datetime :token_expires_at
      t.string :name
      t.string :true_layer_provider_id
      t.timestamps
    end

    create_table :bank_account_holders, id: :uuid do |t|
      t.belongs_to :bank_provider, foreign_key: true, null: false, type: :uuid
      t.json :true_layer_response
      t.string :full_name
      t.json :addresses
      t.date :date_of_birth
      t.timestamps
    end

    create_table :bank_accounts, id: :uuid do |t|
      t.belongs_to :bank_provider, foreign_key: true, null: false, type: :uuid
      t.json :true_layer_response
      t.json :true_layer_balance_response
      t.string :true_layer_id
      t.string :name
      t.string :currency
      t.string :account_number
      t.string :sort_code
      t.decimal :balance
      t.timestamps
    end

    create_table :bank_transactions, id: :uuid do |t|
      t.belongs_to :bank_account, foreign_key: true, null: false, type: :uuid
      t.json :true_layer_response
      t.string :true_layer_id
      t.string :description
      t.decimal :amount
      t.string :currency
      t.string :operation
      t.string :merchant
      t.datetime :happened_at
      t.timestamps
    end

    create_table :bank_errors, id: :uuid do |t|
      t.belongs_to :applicant, foreign_key: true, null: false, type: :uuid
      t.string :bank_name
      t.text :error
      t.timestamps
    end
  end
end
