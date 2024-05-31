class AddCorrespondenceAddressChoiceToApplicant < ActiveRecord::Migration[7.1]
  def change
    add_column :applicants, :correspondence_address_choice, :string
  end
end
