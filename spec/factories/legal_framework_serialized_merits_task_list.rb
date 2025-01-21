FactoryBot.define do
  factory :legal_framework_serializable_merits_task_list, class: "LegalFramework::SerializableMeritsTaskList" do
    initialize_with { new(**lfa_response) }

    lfa_response do
      {
        request_id: SecureRandom.uuid,
        application: {
          tasks: {
            latest_incident_details: [],
            opponent_name: [],
            opponent_mental_capacity: [],
            domestic_abuse_summary: [],
            children_application: [],
            statement_of_case: [],
            why_matter_opposed: [],
            laspo: [],
          },
        },
        proceedings: [
          {
            ccms_code: "DA001",
            tasks: {
              chances_of_success: [],
            },
          },
          {
            ccms_code: "SE014",
            tasks: {
              chances_of_success: [],
              children_proceeding: [:children_application],
              attempts_to_settle: [],
            },
          },
        ],
      }
    end

    trait :da001 do
      lfa_response do
        {
          request_id: SecureRandom.uuid,
          application: {
            tasks: {
              latest_incident_details: [],
              opponent_name: [],
              opponent_mental_capacity: [],
              domestic_abuse_summary: [],
              statement_of_case: [],
            },
          },
          proceedings: [
            {
              ccms_code: "DA001",
              tasks: {
                chances_of_success: [],
              },
            },
          ],
        }
      end
    end

    trait :da001_da004_se014 do
      lfa_response do
        {
          request_id: SecureRandom.uuid,
          application: {
            tasks: {
              latest_incident_details: [],
              opponent_name: [],
              opponent_mental_capacity: [],
              domestic_abuse_summary: [],
              children_application: [],
              statement_of_case: [],
              why_matter_opposed: [],
              laspo: [],
            },
          },
          proceedings: [
            {
              ccms_code: "DA001",
              tasks: {
                chances_of_success: [],
              },
            },
            {
              ccms_code: "DA004",
              tasks: {
                chances_of_success: [],
              },
            },
            {
              ccms_code: "SE014",
              tasks: {
                chances_of_success: [],
                children_proceeding: [:children_application],
                attempts_to_settle: [],
              },
            },
          ],
        }
      end
    end

    trait :da001_da004_as_defendant_se014 do
      lfa_response do
        {
          request_id: SecureRandom.uuid,
          application: {
            tasks: {
              latest_incident_details: [],
              opponent_name: [],
              opponent_mental_capacity: [],
              domestic_abuse_summary: [],
              client_denial_of_allegation: [],
              client_offer_of_undertakings: [],
              children_application: [],
              statement_of_case: [],
              why_matter_opposed: [],
              laspo: [],
            },
          },
          proceedings: [
            {
              ccms_code: "DA001",
              tasks: {
                chances_of_success: [],
              },
            },
            {
              ccms_code: "DA004",
              tasks: {
                chances_of_success: [],
              },
            },
            {
              ccms_code: "SE014",
              tasks: {
                chances_of_success: [],
                children_proceeding: [:children_application],
                attempts_to_settle: [],
              },
            },
          ],
        }
      end
    end

    trait :da001_da005_as_applicant do
      lfa_response do
        {
          request_id: SecureRandom.uuid,
          application: {
            tasks: {
              latest_incident_details: [],
              opponent_name: [],
              opponent_mental_capacity: [],
              domestic_abuse_summary: [],
              statement_of_case: [],
            },
          },
          proceedings: [
            {
              ccms_code: "DA001",
              tasks: {
                chances_of_success: [],
              },
            },
            {
              ccms_code: "DA005",
              tasks: {
                chances_of_success: [],
              },
            },
          ],
        }
      end
    end

    trait :da001_as_defendant do
      lfa_response do
        {
          request_id: SecureRandom.uuid,
          application: {
            tasks: {
              latest_incident_details: [],
              opponent_name: [],
              opponent_mental_capacity: [],
              domestic_abuse_summary: [],
              statement_of_case: [],
              client_denial_of_allegation: [],
              client_offer_of_undertakings: [],
            },
          },
          proceedings: [
            {
              ccms_code: "DA001",
              tasks: {
                chances_of_success: [],
              },
            },
          ],
        }
      end
    end

    trait :da001_as_defendant_and_child_section_8 do
      lfa_response do
        {
          request_id: SecureRandom.uuid,
          application: {
            tasks: {
              latest_incident_details: [],
              opponent_name: [],
              opponent_mental_capacity: [],
              domestic_abuse_summary: [],
              statement_of_case: [],
              client_denial_of_allegation: [],
              client_offer_of_undertakings: [],
              children_application: [],
              why_matter_opposed: [],
              laspo: [],
            },
          },
          proceedings: [
            {
              ccms_code: "DA001",
              tasks: {
                chances_of_success: [],
              },
            },
            {
              ccms_code: "SE014",
              tasks: {
                chances_of_success: [],
                children_proceeding: [:children_application],
                attempts_to_settle: [],
              },
            },
          ],
        }
      end
    end

    trait :da001_as_defendant_se003 do
      lfa_response do
        {
          request_id: SecureRandom.uuid,
          application: {
            tasks: {
              latest_incident_details: [],
              opponent_name: [],
              opponent_mental_capacity: [],
              statement_of_case: [],
              client_denial_of_allegation: [],
              client_offer_of_undertakings: [],
              children_application: [],
              why_matter_opposed: [],
              laspo: [],
            },
          },
          proceedings: [
            {
              ccms_code: "DA001",
              tasks: {
                chances_of_success: [],
                opponents_application: [],
              },
            },
            {
              ccms_code: "SE003",
              tasks: {
                chances_of_success: [],
                children_proceeding: [:children_application],
                attempts_to_settle: [],
                prohibited_steps: [],
              },
            },
          ],
        }
      end
    end

    trait :da001_and_se004 do
      lfa_response do
        {
          request_id: SecureRandom.uuid,
          application: {
            tasks: {
              latest_incident_details: [],
              opponent_name: [],
              opponent_mental_capacity: [],
              domestic_abuse_summary: [],
              statement_of_case: [],
              client_denial_of_allegation: [],
              client_offer_of_undertakings: [],
              children_application: [],
              why_matter_opposed: [],
              laspo: [],
            },
          },
          proceedings: [
            {
              ccms_code: "DA001",
              tasks: {
                chances_of_success: [],
              },
            },
            {
              ccms_code: "SE004",
              tasks: {
                chances_of_success: [],
                children_proceeding: [:children_application],
                attempts_to_settle: [],
                specific_issue: [],
              },
            },
          ],
        }
      end
    end

    trait :da001_and_child_section_8_with_delegated_functions do
      lfa_response do
        {
          request_id: SecureRandom.uuid,
          application: {
            tasks: {
              latest_incident_details: [],
              opponent_name: [],
              opponent_mental_capacity: [],
              domestic_abuse_summary: [],
              statement_of_case: [],
              nature_of_urgency: [],
              children_application: [],
              why_matter_opposed: [],
            },
          },
          proceedings: [
            {
              ccms_code: "DA001",
              tasks: {
                chances_of_success: [],
              },
            },
            {
              ccms_code: "SE014",
              tasks: {
                chances_of_success: [],
                children_proceeding: [:children_application],
                attempts_to_settle: [],
              },
            },
          ],
        }
      end
    end

    trait :da002_as_applicant do
      lfa_response do
        {
          request_id: SecureRandom.uuid,
          application: {
            tasks: {
              latest_incident_details: [],
              opponent_name: [],
              opponent_mental_capacity: [],
              domestic_abuse_summary: [],
              statement_of_case: [],
              nature_of_urgency: [],
            },
          },
          proceedings: [
            {
              ccms_code: "DA002",
              tasks: {
                chances_of_success: [],
                vary_order: [],
              },
            },
          ],
        }
      end
    end

    trait :da002_da006_as_applicant do
      lfa_response do
        {
          request_id: SecureRandom.uuid,
          application: {
            tasks: {
              latest_incident_details: [],
              opponent_name: [],
              opponent_mental_capacity: [],
              domestic_abuse_summary: [],
              statement_of_case: [],
              nature_of_urgency: [],
            },
          },
          proceedings: [
            {
              ccms_code: "DA002",
              tasks: {
                chances_of_success: [],
                vary_order: [],
              },
            },
            {
              ccms_code: "DA006",
              tasks: {
                chances_of_success: [],
                vary_order: [],
              },
            },
          ],
        }
      end
    end

    trait :pb003_pb059 do
      lfa_response do
        {
          request_id: "2a614e1a-a3d5-49ca-949a-c3248483d274",
          success: true,
          application: {
            tasks: {
              opponent_name: [],
              children_application: [],
            },
          },
          proceedings: [
            {
              ccms_code: "PB003",
              tasks: {
                children_proceeding: [:children_application],
                client_relationship_to_proceeding: [],
              },
            },
            {
              ccms_code: "PB059",
              tasks: {
                children_proceeding: [:children_application],
                client_relationship_to_proceeding: [],
              },
            },
          ],
        }
      end
    end

    trait :pb059_with_no_tasks do
      lfa_response do
        {
          request_id: "2a614e1a-a3d5-49ca-949a-c3248483d274",
          success: true,
          application: {
            tasks: {
              opponent_name: [],
            },
          },
          proceedings: [
            {
              ccms_code: "PB059",
              tasks: {},
            },
          ],
        }
      end
    end

    trait :pbm01a do
      lfa_response do
        {
          request_id: SecureRandom.uuid,
          application: {
            tasks: {
              opponent_name: [],
              statement_of_case: [],
              children_application: [],
              second_appeal: [],
            },
          },
          proceedings: [
            {
              ccms_code: "PBM01A",
              tasks: {
                children_proceeding: [:children_application],
                chances_of_success: [],
              },
            },
          ],
        }
      end
    end

    trait :pbm32_as_applicant do
      lfa_response do
        {
          request_id: SecureRandom.uuid,
          application: {
            tasks: {
              opponent_name: [],
              statement_of_case: [],
              children_application: [],
            },
          },
          proceedings: [
            {
              ccms_code: "PBM32",
              tasks: {
                children_proceeding: [:children_application],
                chances_of_success: [],
                client_child_care_assessment: [],
              },
            },
          ],
        }
      end
    end

    trait :broken_opponent do
      lfa_response do
        {
          request_id: SecureRandom.uuid,
          application: {
            tasks: {
              latest_incident_details: [],
              opponent_details: [],
              children_application: [],
              statement_of_case: [],
              why_matter_opposed: [],
              laspo: [],
            },
          },
          proceedings: [
            {
              ccms_code: "DA001",
              tasks: {
                chances_of_success: [],
              },
            },
            {
              ccms_code: "SE014",
              tasks: {
                chances_of_success: [],
                children_proceeding: [:children_application],
                attempts_to_settle: [],
              },
            },
          ],
        }
      end
    end
  end
end
