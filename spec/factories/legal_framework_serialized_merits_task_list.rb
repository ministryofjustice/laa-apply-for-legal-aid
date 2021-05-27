FactoryBot.define do
  factory :legal_framework_serializable_merits_task_list, class: LegalFramework::SerializableMeritsTaskList do
    initialize_with { new(**lfa_response) }

    lfa_response do
      {
        request_id: SecureRandom.uuid,
        application: {
          tasks: {
            latest_incident_details: [],
            opponent_details: [],
            children_application: [],
            statement_of_case: []
          }
        },
        proceeding_types: [
          {
            ccms_code: 'DA001',
            tasks: {
              chances_of_success: []
            }
          },
          {
            ccms_code: 'SE014',
            tasks: {
              chances_of_success: [],
              children_proceeding: [:children_application],
              attempts_to_settle: []
            }
          }
        ]
      }
    end
  end
end
