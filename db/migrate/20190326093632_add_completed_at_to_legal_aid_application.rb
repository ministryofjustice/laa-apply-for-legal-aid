class AddCompletedAtToLegalAidApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :legal_aid_applications, :completed_at, :datetime
  end
end
