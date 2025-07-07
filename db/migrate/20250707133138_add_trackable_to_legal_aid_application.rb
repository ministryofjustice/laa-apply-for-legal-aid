class AddTrackableToLegalAidApplication < ActiveRecord::Migration[8.0]
  def change
    add_column :legal_aid_applications, :tracked, :text
  end
end
