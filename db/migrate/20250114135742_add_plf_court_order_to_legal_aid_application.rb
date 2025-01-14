class AddPLFCourtOrderToLegalAidApplication < ActiveRecord::Migration[7.2]
  def change
    add_column :legal_aid_applications, :plf_court_order, :boolean
  end
end
