class AddEmployedToApplicants < ActiveRecord::Migration[6.0]
  def change
    add_column :applicants, :employed, :boolean
  end
end
