class CreateMeritsAssessments < ActiveRecord::Migration[5.2]
  def change
    create_table :merits_assessments, id: :uuid do |t|
      t.belongs_to :legal_aid_application, foreign_key: true, null: false, type: :uuid

      t.timestamps
    end
  end
end
