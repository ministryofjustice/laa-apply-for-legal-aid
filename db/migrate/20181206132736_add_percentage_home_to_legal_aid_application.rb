class AddPercentageHomeToLegalAidApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :legal_aid_applications, :percentage_home, :decimal
  end
end
