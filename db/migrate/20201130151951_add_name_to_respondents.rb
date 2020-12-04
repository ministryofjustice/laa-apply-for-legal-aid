class AddNameToRespondents < ActiveRecord::Migration[6.0]
  def change
    add_column :respondents, :full_name, :string
  end
end
