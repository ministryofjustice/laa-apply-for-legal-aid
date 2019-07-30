module Providers
  # Adds facility to handle save as draft operations.
  # Note that it requires both `legal_aid_application` and `go_forward`
  # So usually depends on `Flowable` and `ApplicationDependable` being included
  # into the host controller
  module Draftable
    ENDPOINT = Flow::KeyPoint.path_for(journey: :providers, key_point: :home).freeze

    def draft_target_endpoint
      ENDPOINT
    end

    def save_continue_or_draft(form)
      draft_selected? ? form.save_as_draft : form.save
      return false if form.invalid?

      continue_or_draft
    end

    def continue_or_draft
      legal_aid_application.update!(draft: draft_selected?)

      if legal_aid_application.draft?
        redirect_to draft_target_endpoint
      else
        go_forward
      end
    end

    def draft_selected?
      params.key?(:draft_button)
    end
  end
end
