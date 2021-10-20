class AddLegalAidApplicationIdToFeedbacks < ActiveRecord::Migration[6.1]
  def change
    add_column :feedbacks, :legal_aid_application_id, :uuid
  end
end
