class AddBenefitCheckerUnavailableToSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :settings, :benefit_checker_unavailable, :boolean, null: false, default: false
  end
end
