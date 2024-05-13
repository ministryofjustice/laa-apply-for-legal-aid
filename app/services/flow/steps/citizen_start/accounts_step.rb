module Flow
  module Steps
    module CitizenStart
      AccountsStep = Step.new(
        path: ->(_) { Steps.urls.citizens_accounts_path(locale: I18n.locale) },
        forward: :additional_accounts,
        check_answers: :check_answers,
      )
    end
  end
end
