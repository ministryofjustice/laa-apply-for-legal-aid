class RemoveFullNameFromOpponent < ActiveRecord::Migration[7.0]
  def change
    raise StandardError, "Opponent table still has full_name values" if full_name_values_present?

    safety_assured do
      remove_column :opponents, :full_name, :string
    end
  end

  def full_name_values_present?
    ApplicationMeritsTask::Opponent::BaseOpponent.where.not(full_name: nil).count.positive?
  end
end
