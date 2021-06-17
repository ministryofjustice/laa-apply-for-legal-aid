class RemoveProceedingBeforeTheCourtsFromChancesOfSuccesses < ActiveRecord::Migration[6.1]
  def change
    remove_column :chances_of_successes, :proceedings_before_the_court, :boolean
    remove_column :chances_of_successes, :details_of_proceedings_before_the_court, :text
  end
end
