class AddConfirmLinkToLinkedApplication < ActiveRecord::Migration[7.1]
  def change
    add_column :linked_applications, :confirm_link, :boolean
  end
end
