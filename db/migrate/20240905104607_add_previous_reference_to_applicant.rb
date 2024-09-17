class AddPreviousReferenceToApplicant < ActiveRecord::Migration[7.1]
  def change
    add_column :applicants, :applied_previously, :boolean
    add_column :applicants, :previous_reference, :string
  end
end
