module Flow
  module Steps
    module ProviderPartner
      ClientHasPartnersStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_client_has_partner_path(application) },
        forward: lambda do |_application, options|
          if options[:has_partner]
            :contrary_interests
          else
            :check_provider_answers
          end
        end,
      )
    end
  end
end
