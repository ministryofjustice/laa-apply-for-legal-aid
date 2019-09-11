class CreateCfeSubmissions < ActiveRecord::Migration[5.2]
  def change
    create_table :cfe_submissions, id: :uuid do |t|
      t.references :legal_aid_application, foreign_key: true, type: :uuid
      t.uuid :assessment_id
      t.string :aasm_state
      t.text :cfe_result
    end
  end
end
