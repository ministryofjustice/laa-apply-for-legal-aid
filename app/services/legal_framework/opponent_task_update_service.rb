module LegalFramework
  class OpponentTaskUpdateService
    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
      @merits_task_list = @legal_aid_application.legal_framework_merits_task_list
      @application_tasks = @merits_task_list.task_list.tasks[:application]
    end

    def self.call(legal_aid_application)
      new(legal_aid_application).call
    end

    def call
      return unless has_legacy_opponent_step?

      @application_tasks << LegalFramework::SerializableMeritsTask.new(:opponent_name, dependencies: [])
      @application_tasks << LegalFramework::SerializableMeritsTask.new(:opponent_mental_capacity, dependencies: [])
      @application_tasks << LegalFramework::SerializableMeritsTask.new(:domestic_abuse_summary, dependencies: [])
      if legacy_opponent_step.state == :complete
        @merits_task_list.mark_as_complete!(:application, :opponent_name)
        @merits_task_list.mark_as_complete!(:application, :opponent_mental_capacity)
        @merits_task_list.mark_as_complete!(:application, :domestic_abuse_summary)
      end
      @merits_task_list.task_list.tasks[:application] = @application_tasks - [legacy_opponent_step]
      @merits_task_list.serialized_data = @merits_task_list.task_list.to_yaml
      @merits_task_list.save!
      Rails.logger.info("OpponentTaskUpdateService - processed for #{@legal_aid_application.id}, original state was #{legacy_opponent_step.state}")
    end

  private

    def legacy_opponent_step
      @application_tasks.detect { |task| task.name == :opponent_details }
    end

    def has_legacy_opponent_step?
      @has_legacy_opponent_step ||= legacy_opponent_step.present?
    end
  end
end
