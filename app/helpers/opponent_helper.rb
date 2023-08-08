module OpponentHelper
  def opponent_url(type, *)
    url = case type
          when "Individual"
            "providers_legal_aid_application_opponent_individual_path"
          when "Organisation"
            "providers_legal_aid_application_opponent_organisation_path"
          else
            raise "type #{type} not supported"
          end
    Rails.application.routes.url_helpers.send(url, *)
  end

  def opponent_type_description(opponent)
    opponent.type == "Individual" ? opponent.type : opponent.description
  end
end
