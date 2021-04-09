class CreateJoinTableApplicationProceedingTypeInvolvedChildren < ActiveRecord::Migration[6.1]
  def change
    create_join_table :involved_children, :application_proceeding_types, column_options: { type: :uuid } do |t|
      t.primary_key :id, :uuid
      t.timestamps
      t.index %i[application_proceeding_type_id involved_child_id], name: 'index_application_proceeding_involved_children'
      t.index %i[involved_child_id application_proceeding_type_id], name: 'index_involved_children_application_proceeding'
    end
  end
end
