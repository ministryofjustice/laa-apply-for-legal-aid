module Flow
  module Steps
    module CitizenStart
      ConsentsStep = Step.new(
        path: ->(_) { Steps.urls.citizens_consent_path(locale: I18n.locale) },
        forward: lambda do |application|
          application.open_banking_consent ? :banks : :contact_providers
        end,
      )
    end
  end
end
