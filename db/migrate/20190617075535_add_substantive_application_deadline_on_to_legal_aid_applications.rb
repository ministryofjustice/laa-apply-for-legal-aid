class AddSubstantiveApplicationDeadlineOnToLegalAidApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :legal_aid_applications, :substantive_application_deadline_on, :date
    add_column :legal_aid_applications, :substantive_application, :boolean
  end
end
