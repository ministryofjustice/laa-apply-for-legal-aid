class AddPartnerMeansAssessmentToSettings < ActiveRecord::Migration[7.0]
  def change
    add_column :settings, :partner_means_assessment, :boolean, null: false, default: false
  end
end
