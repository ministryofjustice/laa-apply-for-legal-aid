class AddLookupDetailsToAddress < ActiveRecord::Migration[5.2]
  def change
    add_column :addresses, :lookup_used, :boolean, null: false, default: false
    add_column :addresses, :lookup_id, :string
  end
end
