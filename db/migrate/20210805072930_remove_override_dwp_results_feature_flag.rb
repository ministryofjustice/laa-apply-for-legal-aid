class RemoveOverrideDWPResultsFeatureFlag < ActiveRecord::Migration[6.1]
  def change
    remove_column :settings, :override_dwp_results, :boolean, default: false
  end
end
