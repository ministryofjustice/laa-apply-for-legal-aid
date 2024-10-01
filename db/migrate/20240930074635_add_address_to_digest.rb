class AddAddressToDigest < ActiveRecord::Migration[7.1]
  def change
    add_column :application_digests, :no_fixed_address, :boolean
  end
end
