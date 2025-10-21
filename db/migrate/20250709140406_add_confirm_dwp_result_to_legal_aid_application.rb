class AddConfirmDWPResultToLegalAidApplication < ActiveRecord::Migration[8.0]
  def change
    add_column :legal_aid_applications, :dwp_result_confirmed, :boolean
  end
end
