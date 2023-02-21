class RemoveOpponentFields < ActiveRecord::Migration[7.0]
  def change
    raise StandardError, "Opponent table has not been migrated" if new_opponent_models_empty?

    safety_assured do
      remove_columns :opponents, :understands_terms_of_court_order,
                    :understands_terms_of_court_order_details,
                    :warning_letter_sent,
                    :warning_letter_sent_details,
                    :police_notified,
                    :police_notified_details,
                    :bail_conditions_set,
                    :bail_conditions_set_details
    end
  end

  def new_opponent_models_empty?
    [
      ApplicationMeritsTask::DomesticAbuseSummary.count,
      ApplicationMeritsTask::PartiesMentalCapacity.count,
    ].sum.zero?
  end
end
