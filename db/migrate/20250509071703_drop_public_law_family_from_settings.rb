class DropPublicLawFamilyFromSettings < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      remove_column :settings, :public_law_family, :boolean, null: false, default: false
    end
  end
end
