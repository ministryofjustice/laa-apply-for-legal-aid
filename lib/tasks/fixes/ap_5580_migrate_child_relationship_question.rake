def uniq_proceeding_relationships(application)
  application.proceedings.map(&:relationship_to_child).uniq
end

def all_proceeding_states(application)
  application.legal_framework_merits_task_list.task_list.tasks[:proceedings].keys.each_with_object([]) do |proceeding, i|
    proc_tasks = application.legal_framework_merits_task_list.task_list.tasks[:proceedings][proceeding][:tasks]
    i << proc_tasks.find { |task| task.name == :client_relationship_to_proceeding }.state
  end
end

def all_proceedings_complete?(application)
  all_proceeding_states(application).all?(:complete)
end

namespace :fixes do
  desc "Move unanswered child relationship questions from proceedings to application"
  task :ap_5580, [:dry_run] => :environment do |_task, args|
    args.with_defaults(dry_run: "true")
    dry_run = args[:dry_run].to_s.downcase.strip != "false"

    if dry_run
      Rails.logger.info "----------------------------------------"
      Rails.logger.info "dry_run enabled."
      Rails.logger.info "No actual changes will be made."
      Rails.logger.info "----------------------------------------"
    end

    # possibly affected applications
    paa = LegalFramework::MeritsTaskList.where("serialized_data LIKE :input", input: "%client_relationship_to_proceeding%").map(&:legal_aid_application)
    result = { total: paa.count, discarded: 0, completed: 0, issues: 0, fixes: 0, data: [] }
    paa.each do |application|
      application_proceedings = application.legal_framework_merits_task_list.task_list.tasks[:proceedings]
      count = application_proceedings.each_key { |k| application_proceedings[k][:tasks].count { |task| task.name == :client_relationship_to_proceeding } }.count

      output_array = [
        application.id,
        application.application_ref,
        count,
      ]
      if application.discarded?
        output_array << "no problem, discarded"
        result[:discarded] += 1
      elsif all_proceedings_complete?(application)
        output_array << "no problem, completed"
        result[:completed] += 1
        output_array << application.proceedings.map(&:relationship_to_child).uniq
      elsif dry_run
        proceeding_states = all_proceeding_states(application).uniq
        output_array << [
          [application_proceedings.keys],
          proceeding_states,
          proceeding_states.count == 1 ? "fixable" : "cannot auto repair",
        ]
        result[:issues] += 1
      else
        result[:issues] += 1
        proceeding_states = all_proceeding_states(application).uniq

        if proceeding_states.count == 1 && uniq_proceeding_relationships(application).count == 1
          ActiveRecord::Base.transaction do
            # create new framework task
            new_task = LegalFramework::SerializableMeritsTask.new(:client_relationship_to_children)
            # Add it to the application object
            application.legal_framework_merits_task_list.task_list.tasks[:application] << new_task
            application.legal_framework_merits_task_list.task_list.tasks[:application].flatten!
            # loop proceedings and delete the client_relationship_to_proceeding tasks
            application.legal_framework_merits_task_list.task_list.tasks[:proceedings].each_key do |proceeding|
              application.legal_framework_merits_task_list.task_list.tasks[:proceedings][proceeding][:tasks].reject! { |task| task.name == :client_relationship_to_proceeding }
            end
            # save the new list of tasks
            application.legal_framework_merits_task_list.serialized_data = application.legal_framework_merits_task_list.task_list.to_yaml
            application.legal_framework_merits_task_list.save!

            # move the single answer from proceeding to applicant
            application.applicant.update!(relationship_to_children: uniq_proceeding_relationships(application).first)
          end

          result[:fixes] += 1
          output_array << %w[fixed]
        else
          output_array << [
            [application_proceedings.keys],
            proceeding_states,
            "cannot auto repair",
          ]
        end
      end
      result[:data] << [output_array.compact_blank].flatten!
    end
    pp result
  end
end
