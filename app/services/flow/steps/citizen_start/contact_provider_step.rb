module Flow
  module Steps
    module CitizenStart
      ContactProviderStep = Step.new(
        path: ->(_) { Steps.urls.citizens_contact_provider_path(locale: I18n.locale) },
      )
    end
  end
end
