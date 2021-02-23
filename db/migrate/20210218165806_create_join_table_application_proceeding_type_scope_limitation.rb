class CreateJoinTableApplicationProceedingTypeScopeLimitation < ActiveRecord::Migration[6.1]
  def change
    create_join_table :application_proceeding_types, :scope_limitations, column_options: { type: :uuid }, table_name: :assigned_scope_limitations do |t|
      t.primary_key :id, :uuid
      t.timestamps
      # t.uuid :legal_aid_application_id
    end
  end
end
