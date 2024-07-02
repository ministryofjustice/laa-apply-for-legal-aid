class AddTargetApplicationToLinkedApplications < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_reference :linked_applications, :target_application, type: :uuid, index: {algorithm: :concurrently}
  end
end
