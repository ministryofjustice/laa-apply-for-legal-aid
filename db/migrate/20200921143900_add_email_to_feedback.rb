class AddEmailToFeedback < ActiveRecord::Migration[6.0]
  def change
    add_column :feedbacks, :email, :string
    add_column :feedbacks, :originating_page, :string
  end
end
