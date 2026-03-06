class RemoveAuthSubjectUidFromProvider < ActiveRecord::Migration[8.1]
  def change
    safety_assured { remove_column :providers, :auth_subject_uid, :string }
  end
end
