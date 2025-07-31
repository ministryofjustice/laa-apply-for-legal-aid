class CreateSchedules < ActiveRecord::Migration[8.0]
  def change
    create_table :schedules, id: :uuid do |t|
      t.belongs_to :office, foreign_key: true, null: false, type: :uuid
      t.string :area_of_law
      t.string :category_of_law
      t.string :authorisation_status
      t.string :status
      t.date :start_date
      t.date :end_date
      t.boolean :cancelled
      t.integer :license_indicator
      t.string :devolved_power_status
      t.timestamps
    end
  end
end
