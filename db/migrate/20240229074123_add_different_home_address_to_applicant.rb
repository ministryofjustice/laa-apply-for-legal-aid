class AddDifferentHomeAddressToApplicant < ActiveRecord::Migration[7.1]
  def change
    add_column :applicants, :different_home_address, :boolean
  end
end
