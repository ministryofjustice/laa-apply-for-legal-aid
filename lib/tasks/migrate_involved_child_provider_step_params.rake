namespace :migrate do
  desc "AP-6656: Migrate involved_child provider_step_params"
  # Rake task to update provider_step_params where provider_step involved_children.
  # Call with "rake migrate:migrate_involved_child_provider_step_params[mock]"
  # e.g. rake "migrate:migrate_involved_child_provider_step_params[false]"
  # Running with mock=true will output the number of records to be updated without actually updating any
  # (to allow for testing).

  task :migrate_involved_child_provider_step_params, %i[mock] => :environment do |task, args|
    mock = args[:mock].to_s.downcase.strip != "false"
    Rails.logger.info "#{task}: mock=#{mock}"
    applications = LegalAidApplication.where(provider_step: "involved_children")
    Rails.logger.info "#{task}: Updating #{applications.count} provider_step_params"
    applications_count = 0
    applications.each do |application|
      applications_count += 1
      params = application.provider_step_params
      next unless params.key?("application_merits_task_involved_child")

      full_name = params["application_merits_task_involved_child"]["full_name"]

      if full_name.present?
        # This mirrors the logic in NameSplitHelper#split_name
        name_parts = full_name.squish.split
        last_name = name_parts.pop
        first_name = name_parts.join(" ")
        first_name = "unspecified" if first_name.blank?
      end

      params["application_merits_task_involved_child"]["first_name"] = first_name || ""
      params["application_merits_task_involved_child"]["last_name"] = last_name || ""
      next if mock

      application.provider_step_params = params
      application.save!(touch: false) # this prevents the updated_at date being changed and delaying purging of stale records
    end
    Rails.logger.info "#{task}: #{applications_count} applications updated"
  end
end
