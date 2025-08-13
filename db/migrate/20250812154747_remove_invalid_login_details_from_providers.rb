class RemoveInvalidLoginDetailsFromProviders < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      remove_column :providers, :invalid_login_details, :string, default: nil
    end
  end
end
