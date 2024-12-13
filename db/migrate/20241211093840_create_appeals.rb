class CreateAppeals < ActiveRecord::Migration[7.2]
  def change
    create_table :appeals, id: :uuid do |t|
      t.belongs_to :legal_aid_application, foreign_key: true, null: false, type: :uuid
      t.boolean :second_appeal
      t.string :original_judge_level
      t.string :court_type

      t.timestamps
    end
  end
end
