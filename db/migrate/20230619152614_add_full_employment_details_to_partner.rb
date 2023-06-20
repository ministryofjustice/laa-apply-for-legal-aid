class AddFullEmploymentDetailsToPartner < ActiveRecord::Migration[7.0]
  def change
    add_column :partners, :full_employment_details, :string
  end
end
