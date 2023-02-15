class AddTrueLayerProviderIdApplicantIndexToBankProviders < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :bank_providers, [:true_layer_provider_id, :applicant_id], unique: true, algorithm: :concurrently
  end
end
