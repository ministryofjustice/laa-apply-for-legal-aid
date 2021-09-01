class AddAlertViaSentryToSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :settings, :alert_via_sentry, :boolean, null: false, default: false
  end
end
