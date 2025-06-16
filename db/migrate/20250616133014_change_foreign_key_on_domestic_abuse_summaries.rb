class ChangeForeignKeyOnDomesticAbuseSummaries < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :domestic_abuse_summaries, :legal_aid_applications
    add_foreign_key :domestic_abuse_summaries, :legal_aid_applications, on_delete: :cascade, validate: false
  end
end
