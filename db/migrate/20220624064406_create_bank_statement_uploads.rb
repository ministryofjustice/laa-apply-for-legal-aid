class CreateBankStatementUploads < ActiveRecord::Migration[7.0]
  def change
    create_table :bank_statement_uploads, id: :uuid do |t|
      t.belongs_to :legal_aid_application, foreign_key: true, null: false, type: :uuid
      t.timestamps
    end

    add_reference :bank_statement_uploads, :provider_uploader, type: :uuid, index: true
    add_foreign_key :bank_statement_uploads, :providers, column: :provider_uploader_id
  end
end
