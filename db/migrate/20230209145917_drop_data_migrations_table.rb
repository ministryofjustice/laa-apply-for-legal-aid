class DropDataMigrationsTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :data_migrations, force: :cascade, if_exists: true, primary_key: :version, id: :string
  end
end
