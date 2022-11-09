class AddHasNationalInsuranceNumberToApplicant < ActiveRecord::Migration[7.0]
  def change
    add_column :applicants, :has_national_insurance_number, :boolean, null: true
  end
end
