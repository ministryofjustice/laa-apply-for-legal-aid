class AddApplicationProceedingTypeAssociationToChancesOfSuccesses < ActiveRecord::Migration[6.1]
  def change
    add_reference :chances_of_successes, :application_proceeding_type, index: true, type: :uuid
  end
end
