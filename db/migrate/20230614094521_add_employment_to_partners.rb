class AddEmploymentToPartners < ActiveRecord::Migration[7.0]
  def change
    add_column :partners, :employed, :boolean
    add_column :partners, :self_employed, :boolean
    add_column :partners, :armed_forces, :boolean
  end
end
