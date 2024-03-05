class AddSameCorrespondenceAndHomeAddressToApplicant < ActiveRecord::Migration[7.1]
  def change
    add_column :applicants, :same_correspondence_and_home_address, :boolean
  end
end
