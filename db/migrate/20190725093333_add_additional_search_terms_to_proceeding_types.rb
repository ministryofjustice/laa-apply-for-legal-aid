class AddAdditionalSearchTermsToProceedingTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :proceeding_types, :additional_search_terms, :string
  end
end
