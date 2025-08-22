class ChangeUsernameNullableOnProvider < ActiveRecord::Migration[8.0]
  def change
    change_column_null :providers, :username, true
  end
end
