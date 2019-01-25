class CreateFeedbacks < ActiveRecord::Migration[5.2]
  def change
    create_table :feedbacks, id: :uuid do |t|
      t.boolean :done_all_needed
      t.integer :satisfaction
      t.text :improvement_suggestion
      t.timestamps
    end
  end
end
