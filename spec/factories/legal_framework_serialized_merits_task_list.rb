FactoryBot.define do
  factory :legal_framework_merits_task_list, class: LegalFramework::SerializableMeritsTaskList do
    initialize_with { new(lfa_response) }

    lfa_response do
      {
        request_id: SecureRandom.uuid,
        application: {
          tasks: {
            incident_details: [],
            opponent_details: [],
            application_children: []
          }
        },
        proceeding_types: [
          {
            ccms_code: 'DA005',
            tasks: {
              chances_of_success: []
            }
          },
          {
            ccms_code: 'SE003',
            tasks: {
              chances_of_success: [],
              proceeding_children: [:application_children]
            }
          }
        ]
      }
    end
  end
end
