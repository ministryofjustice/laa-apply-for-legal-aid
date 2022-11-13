class BackfillApplicantHasNationalInsuranceNumber < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    Applicant.unscoped.where.not(national_insurance_number: nil).in_batches do |relation|
      relation.update_all(has_national_insurance_number: true)
    end
  end
end
