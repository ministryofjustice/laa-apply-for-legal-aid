class AddCCMSMatterCodeToProceedings < ActiveRecord::Migration[6.1]
  def change
    add_column :proceedings, :ccms_matter_code, :string
  end
end
