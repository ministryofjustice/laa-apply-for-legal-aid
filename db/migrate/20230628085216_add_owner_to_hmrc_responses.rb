class AddOwnerToHMRCResponses < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      change_table :hmrc_responses, bulk: true do |t|
        t.belongs_to :owner, polymorphic: true, type: :uuid
      end
    end
  end
end
