class AddSeparateRepresentationRequiredToLegalAidApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :legal_aid_applications, :separate_representation_required, :boolean
  end
end
