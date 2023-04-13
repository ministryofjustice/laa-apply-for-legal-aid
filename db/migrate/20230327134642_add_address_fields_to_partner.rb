class AddAddressFieldsToPartner < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      change_table :partners, bulk: true do |t|
        t.boolean :shared_address_with_client
        t.string :address_line_one
        t.string :address_line_two
        t.string :city
        t.string :county
        t.string :postcode
        t.string :organisation
        t.boolean :lookup_used, default: false, null: false
        t.string :lookup_id
      end
    end
  end
end
