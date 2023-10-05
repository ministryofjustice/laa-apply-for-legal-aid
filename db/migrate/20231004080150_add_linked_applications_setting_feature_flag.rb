class AddLinkedApplicationsSettingFeatureFlag < ActiveRecord::Migration[7.0]
  def change
    add_column :settings, :linked_applications, :boolean, null: false, default: false
  end
end
