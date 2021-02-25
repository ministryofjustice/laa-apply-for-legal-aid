class CreateJoinTableApplicationProceedingTypeScopeLimitation < ActiveRecord::Migration[6.1]
  def change
    create_join_table :application_proceeding_types, :scope_limitations, column_options: { type: :uuid } do |t|
      t.primary_key :id, :uuid
      t.timestamps
    end
  end
end
