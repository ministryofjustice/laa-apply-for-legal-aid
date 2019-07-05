class AddInFullTimeEducationToDependants < ActiveRecord::Migration[5.2]
  def change
    add_column :dependants, :in_full_time_education, :boolean
  end
end
