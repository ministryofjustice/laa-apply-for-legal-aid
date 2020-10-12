class AddDiscardedAtToLegalAidApplication < ActiveRecord::Migration[6.0]
  def change
    add_column :legal_aid_applications, :discarded_at, :datetime
    add_index :legal_aid_applications, :discarded_at
  end
end
