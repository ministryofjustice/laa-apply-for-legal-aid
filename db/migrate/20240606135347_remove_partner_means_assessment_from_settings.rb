class RemovePartnerMeansAssessmentFromSettings < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      remove_column :settings, :partner_means_assessment, :boolean, null: false, default: false
    end
  end
end
