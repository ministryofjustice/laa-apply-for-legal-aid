module Flow
  class MeritsLoop
    def initialize(legal_aid_application, group)
      @legal_aid_application = legal_aid_application
      @group = group
    end

    def self.forward_flow(legal_aid_application, group)
      new(legal_aid_application, group).forward_flow
    end

    def forward_flow
      next_task
    end

  private

    def next_task
      return first_task_name if not_started_tasks.any?

      :merits_task_lists
    end

    def first_task_name
      not_started_tasks.first[:name]
    end

    def convert_task_to_flow_name(task)
      {
        latest_incident_details: :date_client_told_incidents,
        opponent_name: :start_opponent_task,
        opponent_mental_capacity: :opponents_mental_capacities,
        domestic_abuse_summary: :domestic_abuse_summaries,
        statement_of_case: :statement_of_cases,
        children_application: :start_involved_children_task,
        children_proceeding: :linked_children,
        why_matter_opposed: :matter_opposed_reasons,
        attempts_to_settle: :attempts_to_settle,
        chances_of_success: :chances_of_success,
        client_denial_of_allegation: :client_denial_of_allegations,
        client_offer_of_undertakings: :client_offered_undertakings,
        specific_issue: :specific_issue,
        prohibited_steps: :prohibited_steps,
        laspo: :in_scope_of_laspos,
        nature_of_urgency: :nature_of_urgencies,
        second_appeal: :second_appeals,
        vary_order: :vary_order,
        opponents_application: :opponents_application,
        client_relationship_to_children: :application_merits_task_client_is_biological_parent,
        client_relationship_to_proceeding: :is_client_biological_parent,
        client_child_care_assessment: :child_care_assessments,
        court_order_copy: :court_order_copies,
        matter_opposed: :is_matter_opposed,
      }[task]
    end

    def not_started_tasks
      @not_started_tasks ||= grouped_tasks.filter_map do |task|
        next unless task.state == :not_started

        {
          name: convert_task_to_flow_name(task.name),
          task_name: task.name,
          url: I18n.t(task.name, scope: "providers.merits_task_lists.show.urls"),
          state: task.state,
        }
      end
    end

    def grouped_tasks
      all_tasks = @legal_aid_application.reload.legal_framework_merits_task_list.task_list.tasks

      if @group.to_sym == :application
        all_tasks[:application]
      else
        all_tasks.dig(:proceedings, @group.to_sym)[:tasks]
      end
    end
  end
end
