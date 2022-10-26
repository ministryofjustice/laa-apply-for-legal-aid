class CreateSpecificIssue < ActiveRecord::Migration[7.0]
  def change
    create_table :specific_issues, id: :uuid do |t|
      t.belongs_to :proceeding, null: false, foreign_key: true, type: :uuid
      t.boolean :confirmed
      t.string :details

      t.timestamps
    end
  end
end
