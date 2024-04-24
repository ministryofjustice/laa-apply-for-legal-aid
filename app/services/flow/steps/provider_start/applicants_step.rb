module Flow
  module Steps
    module ProviderStart
      ApplicantsStep = Step.new(
        path: ->(_) { Steps.urls.new_providers_applicant_path },
        forward: :correspondence_address_lookups,
      )
    end
  end
end
