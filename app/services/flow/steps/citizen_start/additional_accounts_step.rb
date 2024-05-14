module Flow
  module Steps
    module CitizenStart
      AdditionalAccountsStep = Step.new(
        path: ->(_) { Steps.urls.citizens_additional_accounts_path(locale: I18n.locale) },
        forward: lambda do |application|
          application.has_offline_accounts? ? :contact_providers : :check_answers
        end,
      )
    end
  end
end
