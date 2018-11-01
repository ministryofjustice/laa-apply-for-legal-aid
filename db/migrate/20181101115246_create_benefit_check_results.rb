class CreateBenefitCheckResults < ActiveRecord::Migration[5.2]
  def change
    create_table :benefit_check_results do |t|
      t.belongs_to :legal_aid_application, index: true
      t.string :result
      t.string :dwp_ref
      t.timestamps
    end
  end
end
