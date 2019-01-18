class AddProviderStepToLegalAidApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :legal_aid_applications, :provider_step, :string
  end
end
