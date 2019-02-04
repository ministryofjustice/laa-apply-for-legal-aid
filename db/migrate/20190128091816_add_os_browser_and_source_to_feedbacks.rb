class AddOsBrowserAndSourceToFeedbacks < ActiveRecord::Migration[5.2]
  def change
    add_column :feedbacks, :os, :string
    add_column :feedbacks, :browser, :string
    add_column :feedbacks, :browser_version, :string
    add_column :feedbacks, :source, :string
  end
end
