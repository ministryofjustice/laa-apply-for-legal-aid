module Flow
  module Steps
    module ProviderMerits
      RemoveInvolvedChildStep = Step.new(
        path: ->(application, opponent) { Steps.urls.providers_legal_aid_application_remove_involved_child_path(application, opponent) },
        forward: lambda { |application|
          if application.involved_children.count.positive?
            :has_other_involved_children
          else
            :involved_children
          end
        },
      )
    end
  end
end
