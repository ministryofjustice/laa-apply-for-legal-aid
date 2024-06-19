module Flow
  module Steps
    module Partner
      ContraryInterestsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_contrary_interest_path(application) },
        forward: lambda do |_application, options|
          options[:partner_has_contrary_interest] ? :check_provider_answers : :partner_details
        end,
        check_answers: lambda do |_application, options|
          options[:partner_has_contrary_interest] ? :check_provider_answers : :partner_details
        end,
      )
    end
  end
end
