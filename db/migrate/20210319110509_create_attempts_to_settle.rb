class CreateAttemptsToSettle < ActiveRecord::Migration[6.1]
  def change
    create_table :attempts_to_settles, id: :uuid do |t|
      t.belongs_to :legal_aid_application, foreign_key: true, null: false, type: :uuid
      t.text :attempts_made
      t.timestamps
    end
  end
end
