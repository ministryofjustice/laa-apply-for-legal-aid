class AddInScopeOfLaspo < ActiveRecord::Migration[6.1]
  def change
    add_column :legal_aid_applications, :in_scope_of_laspo, :boolean
  end
end
