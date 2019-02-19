class CreateLegalAidApplicationTransactionTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :legal_aid_application_transaction_types, id: :uuid do |t|
      t.references :legal_aid_application, index: { name: :laa_trans_type_on_legal_aid_application_id }, type: :uuid
      t.references :transaction_type, index: { name: :laa_trans_type_on_transaction_type_id }, type: :uuid
      t.timestamps
    end
  end
end
