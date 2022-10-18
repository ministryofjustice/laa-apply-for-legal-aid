class CreateAllegation < ActiveRecord::Migration[7.0]
  def change
    create_table :allegations, id: :uuid do |t|
      t.belongs_to :legal_aid_application, null: false, foreign_key: true, type: :uuid
      t.boolean :denies_all
      t.string :additional_information

      t.timestamps
    end
  end
end
