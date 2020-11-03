class CreateCFEResult < ActiveRecord::Migration[5.2]
  def change
    create_table :cfe_results, id: :uuid do |t|
      t.uuid :legal_aid_application_id
      t.uuid :submission_id
      t.text :result
      t.timestamps
    end
  end
end
