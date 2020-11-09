class AddRememberableToApplicant < ActiveRecord::Migration[6.0]
  def change
    add_column :applicants, :remember_created_at, :datetime
    add_column :applicants, :remember_token, :string
  end
end
