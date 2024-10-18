class AlterForeignKeyOnBenefitCheckResult < ActiveRecord::Migration[7.2]
  def change
    remove_foreign_key :benefit_check_results, :legal_aid_applications
    add_foreign_key :benefit_check_results, :legal_aid_applications, on_delete: :cascade, validate: false
  end
end
