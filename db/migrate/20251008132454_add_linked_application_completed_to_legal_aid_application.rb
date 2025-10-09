class AddLinkedApplicationCompletedToLegalAidApplication < ActiveRecord::Migration[8.0]
  def change
    add_column :legal_aid_applications, :linked_application_completed, :boolean
  end
end
