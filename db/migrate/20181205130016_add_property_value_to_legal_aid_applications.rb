class AddPropertyValueToLegalAidApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :legal_aid_applications, :property_value, :decimal, precision: 10, scale: 2
  end
end
