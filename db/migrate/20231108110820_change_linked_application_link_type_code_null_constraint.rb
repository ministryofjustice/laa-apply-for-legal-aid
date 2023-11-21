class ChangeLinkedApplicationLinkTypeCodeNullConstraint < ActiveRecord::Migration[7.0]
  def change
    change_column_null :linked_applications, :link_type_code, true
  end
end
