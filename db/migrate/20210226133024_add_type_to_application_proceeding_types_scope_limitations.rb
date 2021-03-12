class AddTypeToApplicationProceedingTypesScopeLimitations < ActiveRecord::Migration[6.1]
  def change
    add_column :application_proceeding_types_scope_limitations, :type, :string
  end
end
