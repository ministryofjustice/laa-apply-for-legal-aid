class AddSecondAppealToLegalAidApplication < ActiveRecord::Migration[7.2]
  def change
    add_column :legal_aid_applications, :second_appeal, :boolean
  end
end
