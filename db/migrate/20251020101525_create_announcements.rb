class CreateAnnouncements < ActiveRecord::Migration[8.0]
  def change
    create_table :announcements, id: :uuid do |t|
      t.integer :display_type
      t.string :gov_uk_header_bar
      t.string :heading
      t.string :link_display
      t.string :link_url
      t.string :body
      t.datetime :start_at
      t.datetime :end_at

      t.timestamps
    end
  end
end
