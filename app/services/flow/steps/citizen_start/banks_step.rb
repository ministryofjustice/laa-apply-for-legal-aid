module Flow
  module Steps
    module CitizenStart
      BanksStep = Step.new(
        path: ->(_) { Steps.urls.citizens_banks_path(locale: I18n.locale) },
        forward: :true_layer,
      )
    end
  end
end
