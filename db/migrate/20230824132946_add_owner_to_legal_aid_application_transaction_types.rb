class AddOwnerToLegalAidApplicationTransactionTypes < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      change_table :legal_aid_application_transaction_types, bulk: true do |t|
        t.belongs_to :owner, polymorphic: true, type: :uuid
      end
    end
  end
end
