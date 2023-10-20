class AddCopyCaseToLegalAidApplication < ActiveRecord::Migration[7.0]
  def change
    add_column :legal_aid_applications, :copy_case, :boolean
  end
end
