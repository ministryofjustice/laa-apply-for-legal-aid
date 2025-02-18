class AddEcctRoutedToApplicationDigest < ActiveRecord::Migration[7.2]
  def change
    add_column :application_digests, :ecct_routed, :boolean
  end
end
