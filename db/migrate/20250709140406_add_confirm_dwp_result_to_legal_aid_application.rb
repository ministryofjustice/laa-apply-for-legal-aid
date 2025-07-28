class AddConfirmDWPResultToLegalAidApplication < ActiveRecord::Migration[8.0]
  def change
    add_column :legal_aid_applications, :confirm_dwp_result, :text
  end
end
