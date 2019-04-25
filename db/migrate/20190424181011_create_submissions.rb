class CreateSubmissions < ActiveRecord::Migration[5.2]
  def change
    create_table :ccms_submissions, id: :uuid do |t|
      t.references :legal_aid_application, foreign_key: true, type: :uuid
      t.integer :applicant_ccms_reference
      t.integer :case_ccms_reference
      t.string :aasm_state
      t.timestamps
    end
  end
end
