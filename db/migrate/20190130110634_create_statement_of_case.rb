class CreateStatementOfCase < ActiveRecord::Migration[5.2]
  def change
    create_table :statement_of_cases, id: :uuid do |t|
      t.belongs_to :legal_aid_application, foreign_key: true, null: false, type: :uuid
      t.text :statement
      t.timestamps
    end
  end
end
