module OpponentHelper
  def opponent_url(legal_aid_application, opponent)
    if opponent.individual?
      providers_legal_aid_application_opponent_individual_path(legal_aid_application.id, opponent.id)
    elsif opponent.organisation? && opponent.ccms_opponent_id.blank?
      providers_legal_aid_application_opponent_new_organisation_path(legal_aid_application.id, opponent.id)
    end
  rescue StandardError
    nil
  end

  def opponent_type_description(opponent)
    if opponent.individual?
      "Individual"
    elsif opponent.organisation?
      opponent.ccms_type_text
    end
  rescue StandardError
    "Unknown opponent type"
  end
end
