class RenameAptInvolvedChildrenToAptLinkedChildren < ActiveRecord::Migration[6.1]
  def change
    rename_table :application_proceeding_types_involved_children, :application_proceeding_types_linked_children
  end
end
