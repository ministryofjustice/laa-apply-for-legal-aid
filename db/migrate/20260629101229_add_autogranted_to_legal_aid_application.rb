class AddAutograntedToLegalAidApplication < ActiveRecord::Migration[8.1]
  def change
    add_column :legal_aid_applications, :autogranted, :boolean
  end
end
