class AddPublicLawFamilyToSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :settings, :public_law_family, :boolean, null: false, default: false
  end
end
