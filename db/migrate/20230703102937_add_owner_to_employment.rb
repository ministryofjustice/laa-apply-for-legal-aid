class AddOwnerToEmployment < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      change_table :employments, bulk: true do |t|
        t.belongs_to :owner, polymorphic: true, type: :uuid
      end
    end
  end
end
