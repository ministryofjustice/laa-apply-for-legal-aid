class RemoveAddressFieldsFromPartner < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      change_table :partners, bulk: true do |t|
        t.remove :shared_address_with_client
        t.remove :address_line_one
        t.remove :address_line_two
        t.remove :city
        t.remove :county
        t.remove :postcode
        t.remove :organisation
        t.remove :lookup_used
        t.remove :lookup_id
      end
    end
  end
end
