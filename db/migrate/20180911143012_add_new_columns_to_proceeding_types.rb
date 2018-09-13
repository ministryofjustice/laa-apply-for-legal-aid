class AddNewColumnsToProceedingTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :proceeding_types, :ccms_category_law, :string
    add_column :proceeding_types, :ccms_category_law_code, :string
    add_column :proceeding_types, :ccms_matter, :string
    add_column :proceeding_types, :ccms_matter_code, :string
  end
end
