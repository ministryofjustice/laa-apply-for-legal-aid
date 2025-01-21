class CreateChildCareAssessments < ActiveRecord::Migration[7.2]
  def change
    create_table :child_care_assessments, id: :uuid do |t|
      t.belongs_to :proceeding, null: false, foreign_key: true, type: :uuid
      t.boolean :assessed
      t.boolean :result
      t.string :details

      t.timestamps
    end
  end
end
