class AddMeritsSubmittedByToLegalAidApplication < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_reference :legal_aid_applications, :merits_submitted_by, null: true, type: :uuid, index: {algorithm: :concurrently}
  end
end
