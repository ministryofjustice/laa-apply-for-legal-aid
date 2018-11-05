class CreateBenefitCheckResults < ActiveRecord::Migration[5.2]
  def change
    create_table :benefit_check_results, id: :uuid do |t|
      t.belongs_to :legal_aid_application, foreign_key: true, null: false, type: :uuid
      t.string :result
      t.string :dwp_ref
      t.timestamps
    end
  end
end
