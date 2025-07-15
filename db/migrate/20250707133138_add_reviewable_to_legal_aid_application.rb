class AddReviewableToLegalAidApplication < ActiveRecord::Migration[8.0]
  def change
    add_column :legal_aid_applications, :reviewed, :text
  end
end
