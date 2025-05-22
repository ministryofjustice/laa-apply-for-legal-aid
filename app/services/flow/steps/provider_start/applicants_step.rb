module Flow
  module Steps
    module ProviderStart
      ApplicantsStep = Step.new(
        path: ->(_) { Steps.urls.new_providers_applicant_path },
        forward: :has_national_insurance_numbers,
      )
    end
  end
end
