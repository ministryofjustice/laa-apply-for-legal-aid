class AddMatterOpposedToMatterOppositions < ActiveRecord::Migration[7.2]
  def change
    add_column :matter_oppositions, :matter_opposed, :boolean
  end
end
