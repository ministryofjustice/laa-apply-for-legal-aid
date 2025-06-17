class ValidateForeignKeyOnDomesticAbuseSummaries < ActiveRecord::Migration[8.0]
  def change
    validate_foreign_key :domestic_abuse_summaries, :legal_aid_applications
  end
end
