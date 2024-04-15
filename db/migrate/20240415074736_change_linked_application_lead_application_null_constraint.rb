class ChangeLinkedApplicationLeadApplicationNullConstraint < ActiveRecord::Migration[7.1]
  def change
    change_column_null :linked_applications, :lead_application_id, true
  end
end
