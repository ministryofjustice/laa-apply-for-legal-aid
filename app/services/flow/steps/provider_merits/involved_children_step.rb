module Flow
  module Steps
    module ProviderMerits
      InvolvedChildrenStep = Step.new(
        path: lambda do |application, params|
          involved_child_id = params.is_a?(Hash) && params.deep_symbolize_keys[:id]
          case involved_child_id
          when "new"
            partial_record = ApplicationMeritsTask::InvolvedChild.find_by(
              full_name: params.deep_symbolize_keys[:application_merits_task_involved_child][:full_name],
              legal_aid_application_id: application.id,
            )
            if partial_record
              Steps.urls.providers_legal_aid_application_involved_child_path(application, partial_record)
            else
              Steps.urls.new_providers_legal_aid_application_involved_child_path(application)
            end
          when /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ # uuid_regex
            Steps.urls.providers_legal_aid_application_involved_child_path(application, involved_child_id)
          else
            Steps.urls.new_providers_legal_aid_application_involved_child_path(application)
          end
        end,
        forward: :has_other_involved_children,
      )
    end
  end
end
