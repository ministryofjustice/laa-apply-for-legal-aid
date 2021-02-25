class CreateJoinTableApplicationProceedingTypeScopeLimitation < ActiveRecord::Migration[6.1]
  def change
    create_join_table :application_proceeding_types, :scope_limitations, column_options: { type: :uuid } do |t|
      t.primary_key :id, :uuid
      t.timestamps
      t.index %i[application_proceeding_type_id scope_limitation_id], name: 'index_application_proceeding_scope_limitation'
      t.index %i[scope_limitation_id application_proceeding_type_id], name: 'index_scope_limitation_application_proceeding'
    end
  end
end
