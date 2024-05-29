module Flow
  module Steps
    module ProviderMerits
      HasOtherInvolvedChildrenStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_has_other_involved_children_path(application) },
        forward: lambda { |application, has_other_involved_child|
          if has_other_involved_child
            :involved_children
          else
            Flow::MeritsLoop.forward_flow(application, :application)
          end
        },
      )
    end
  end
end
