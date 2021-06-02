class RemoveLegalAidApplicationAssociationFromChancesOfSuccess < ActiveRecord::Migration[6.1]
  def up
    change_table :chances_of_successes do |t|
      t.remove_references :legal_aid_application
    end
  end

  def down
    add_reference :chances_of_successes, :legal_aid_application, foreign_key: true, null: true, type: :uuid
  end
end
