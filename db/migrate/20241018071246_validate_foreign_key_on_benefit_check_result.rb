class ValidateForeignKeyOnBenefitCheckResult < ActiveRecord::Migration[7.2]
  def change
    validate_foreign_key :benefit_check_results, :legal_aid_applications
  end
end
