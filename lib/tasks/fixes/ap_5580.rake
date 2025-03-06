def uniq_proceeding_relationships(application)
  application.proceedings.map(&:relationship_to_child).uniq
end

def all_client_relationship_to_proceeding_states(application)
  application.legal_framework_merits_task_list.task_list.tasks[:proceedings].keys.each_with_object([]) do |proceeding, i|
    proc_tasks = application.legal_framework_merits_task_list.task_list.tasks[:proceedings][proceeding][:tasks]
    i << proc_tasks.find { |task| task.name == :client_relationship_to_proceeding }.state
  end
end

def all_proceedings_complete?(application)
  all_client_relationship_to_proceeding_states(application).all?(:complete)
end

def can_be_migrated?(application)
  all_client_relationship_to_proceeding_states(application).uniq.count == 1 && uniq_proceeding_relationships(application).count == 1
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

    paa = LegalFramework::MeritsTaskList.where("serialized_data LIKE :input", input: "%name: :client_relationship_to_proceeding%").map(&:legal_aid_application)

    results = { affected: paa.count, submitted: 0, answered: 0, fixable: 0, investigate: 0, migrated: 0, data: [] }

    paa.each do |legal_aid_application|
      application_proceedings = legal_aid_application.legal_framework_merits_task_list.task_list.tasks[:proceedings]
      count = application_proceedings.each_key { |k| application_proceedings[k][:tasks].count { |task| task.name == :client_relationship_to_proceeding } }.count

      results[:submitted] += 1 if legal_aid_application.assessment_submitted?
      results[:answered] += 1 if all_proceedings_complete?(legal_aid_application)
      results[:fixable] += 1 if can_be_migrated?(legal_aid_application)
      results[:investigate] += 1 unless can_be_migrated?(legal_aid_application)

      output_hash = {
        id: legal_aid_application.id,
        ref: legal_aid_application.application_ref,
        proceedings: count,
        proceeding_states: all_client_relationship_to_proceeding_states(legal_aid_application).uniq,
        proceeding_answers: uniq_proceeding_relationships(legal_aid_application).sort,
      }

      unless dry_run
        if can_be_migrated?(legal_aid_application) == false
          output_hash[:fixed] = false
        else
          # start transaction
          ActiveRecord::Base.transaction do
            # create new framework task
            new_task = LegalFramework::SerializableMeritsTask.new(:client_relationship_to_children)
            new_task.mark_as_complete! if all_client_relationship_to_proceeding_states(legal_aid_application).uniq == [:complete]
            # Add it to the application object
            legal_aid_application.legal_framework_merits_task_list.task_list.tasks[:application] << new_task
            legal_aid_application.legal_framework_merits_task_list.task_list.tasks[:application].flatten!
            # loop proceedings and delete the client_relationship_to_proceeding tasks
            legal_aid_application.legal_framework_merits_task_list.task_list.tasks[:proceedings].each_key do |proceeding|
              legal_aid_application.legal_framework_merits_task_list.task_list.tasks[:proceedings][proceeding][:tasks].reject! { |task| task.name == :client_relationship_to_proceeding }
            end
            # save the new list of tasks
            legal_aid_application.legal_framework_merits_task_list.serialized_data = legal_aid_application.legal_framework_merits_task_list.task_list.to_yaml
            legal_aid_application.legal_framework_merits_task_list.save!

            # move the single answer from proceeding to applicant
            legal_aid_application.applicant.update!(relationship_to_children: uniq_proceeding_relationships(legal_aid_application).first)

            # repoint the provider_step if on the old versions
            legal_aid_application.update!(provider_step: "application_merits_task_client_is_biological_parent") if legal_aid_application.provider_step == "is_client_biological_parent"
            legal_aid_application.update!(provider_step: "application_merits_task_client_has_parental_responsibilities") if legal_aid_application.provider_step == "does_client_have_parental_responsibilities"
            legal_aid_application.update!(provider_step: "application_merits_task_client_is_child_subject") if legal_aid_application.provider_step == "is_client_child_subject"
            legal_aid_application.update!(provider_step: "application_merits_task_client_check_parental_answers") if legal_aid_application.provider_step == "check_who_client_is"
            results[:migrated] += 1
            output_hash[:fixed] = true
          rescue ActiveRecord::Rollback
            output_hash[:fixed] = false
          end
        end
      end

      results[:data] << output_hash
    end

    pp results
  end
end
