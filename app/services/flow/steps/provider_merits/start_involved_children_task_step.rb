module Flow
  module Steps
    module ProviderMerits
      StartInvolvedChildrenTaskStep = Step.new(
        # This allows the statement of case flow to check for involved children while allowing a standard path
        #  to :involved_children from :has_other_involved_children that always goes to the new children page
        path: lambda do |application|
          if application.involved_children.any?
            Steps.urls.providers_legal_aid_application_has_other_involved_children_path(application)
          else
            Steps.urls.new_providers_legal_aid_application_involved_child_path(application)
          end
        end,
      )
    end
  end
end
