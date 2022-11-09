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
        opponent_details: :opponents,
        statement_of_case: :statement_of_cases,
        children_application: :start_involved_children_task,
        children_proceeding: :linked_children,
        attempts_to_settle: :attempts_to_settle,
        chances_of_success: :chances_of_success,
        client_denial_of_allegation: :client_denial_of_allegations,
        client_offer_of_undertakings: :client_offered_undertakings,
        specific_issue: :specific_issue,
        prohibited_steps: :prohibited_steps,
        laspo: :in_scope_of_laspos,
        nature_of_urgency: :nature_of_urgencies,
        vary_order: :vary_order,
      }[task]
    end

    def not_started_tasks
      @not_started_tasks ||= grouped_tasks.map { |task|
        next unless task.state == :not_started

        {
          name: convert_task_to_flow_name(task.name),
          task_name: task.name,
          url: I18n.t(task.name, scope: "providers.merits_task_lists.task_list_item.urls"),
          state: task.state,
        }
      }&.compact
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
