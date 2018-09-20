class AddEmailAddressToApplicants < ActiveRecord::Migration[5.2]
  def change
    add_column :applicants, :email_address, :string
  end
end
