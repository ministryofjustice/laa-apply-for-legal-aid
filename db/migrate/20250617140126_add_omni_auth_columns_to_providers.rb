class AddOmniAuthColumnsToProviders < ActiveRecord::Migration[8.0]
    def change
    # Omniauthable, custom devise
    add_column :providers, :auth_provider, :string, null: false, default: ""
    add_column :providers, :auth_subject_uid, :string
  end
end
