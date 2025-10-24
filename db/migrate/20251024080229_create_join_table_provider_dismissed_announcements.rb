class CreateJoinTableProviderDismissedAnnouncements < ActiveRecord::Migration[8.0]
  def change
    create_join_table :announcements, :providers, table_name: :provider_dismissed_announcements, column_options: { type: :uuid } do |t|
      t.index [:provider_id, :announcement_id]
    end
  end
end
