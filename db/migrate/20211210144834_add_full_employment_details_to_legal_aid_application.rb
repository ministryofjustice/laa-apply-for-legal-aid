class AddFullEmploymentDetailsToLegalAidApplication < ActiveRecord::Migration[6.1]
  def change
    add_column :legal_aid_applications, :full_employment_details, :string
  end
end
