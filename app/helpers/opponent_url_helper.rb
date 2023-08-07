module OpponentUrlHelper
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
end
