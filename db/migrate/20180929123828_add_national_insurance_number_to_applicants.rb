class AddNationalInsuranceNumberToApplicants < ActiveRecord::Migration[5.2]
  def change
    add_column :applicants, :national_insurance_number, :string
  end
end
