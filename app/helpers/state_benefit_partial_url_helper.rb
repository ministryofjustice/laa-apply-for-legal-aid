module StateBenefitPartialUrlHelper
  def state_benefit_partial_url(type, version, *)
    url = case type
          when :change
            "providers_legal_aid_application_#{version}_state_benefit_path"
          when :remove
            "providers_legal_aid_application_#{version}_remove_state_benefit_path"
          else
            raise "type #{type} not supported"
          end
    Rails.application.routes.url_helpers.send(url, *)
  end
end
