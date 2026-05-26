class CreateLegalAidApplicationProgression < ActiveRecord::Migration[8.1]
  def change
    create_table :legal_aid_application_progressions, id: :uuid do |t|
      t.belongs_to :legal_aid_application, foreign_key: true, null: false, type: :uuid
      t.jsonb :derek
      t.timestamps
    end
  end
end
