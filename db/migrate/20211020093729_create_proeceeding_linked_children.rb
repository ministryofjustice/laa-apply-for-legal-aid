class CreateProeceedingLinkedChildren < ActiveRecord::Migration[6.1]
  def change
    create_table :proceedings_linked_children, id: :uuid do |t|
      t.uuid :proceeding_id
      t.uuid :involved_child_id

      t.timestamps
    end

    add_index :proceedings_linked_children, %w[proceeding_id involved_child_id], name: 'index_proceeding_involved_child', unique: true
    add_index :proceedings_linked_children, %w[involved_child_id proceeding_id], name: 'index_involved_child_proceeding', unique: true
  end
end
