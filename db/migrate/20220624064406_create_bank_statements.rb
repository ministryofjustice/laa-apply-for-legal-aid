class CreateBankStatements < ActiveRecord::Migration[7.0]
  def change
    create_table :bank_statements, id: :uuid do |t|
      t.belongs_to :legal_aid_application, foreign_key: true, null: false, type: :uuid
      t.belongs_to :attachment, foreign_key: true, type: :uuid
      t.timestamps
    end

    add_reference :bank_statements, :provider_uploader, type: :uuid, index: true
    add_foreign_key :bank_statements, :providers, column: :provider_uploader_id
  end
end
