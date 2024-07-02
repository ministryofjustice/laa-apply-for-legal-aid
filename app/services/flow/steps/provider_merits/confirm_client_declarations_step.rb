module Flow
  module Steps
    module ProviderMerits
      ConfirmClientDeclarationsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_confirm_client_declaration_path(application) },
        forward: :review_and_print_applications,
      )
    end
  end
end
