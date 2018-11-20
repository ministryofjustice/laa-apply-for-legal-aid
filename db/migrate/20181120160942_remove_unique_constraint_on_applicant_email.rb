class RemoveUniqueConstraintOnApplicantEmail < ActiveRecord::Migration[5.2]
  def up
    remove_index :applicants, :email
    add_index :applicants, :email, unique: false
  end

  def down
    remove_index :applicants, :email
    add_index :applicants, :email, unique: true
  end
end
