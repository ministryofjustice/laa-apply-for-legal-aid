namespace :migrate do
  desc "AP-6656: Populate involved children first and last names from their full name"
  # Rake task to populate involved children first and last names from their full name.
  # Call with "rake migrate:migrate_involved_children_names[mock]"
  # e.g. rake "migrate:migrate_involved_children_names[false]"
  # Running with mock=true will output the number of records to be updated without actually updating any
  # (to allow for testing).

  task :migrate_involved_children_names, %i[mock] => :environment do |task, args|
    mock = args[:mock].to_s.downcase.strip != "false"
    Rails.logger.info "#{task}: mock=#{mock}"
    involved_children = ApplicationMeritsTask::InvolvedChild.where(last_name: nil)
    involved_children_count = involved_children.count
    Rails.logger.info "#{task}: Updating #{involved_children_count} involved children"
    involved_children.in_batches do |batch|
      batch.each do |child|
        first_name, last_name = child.split_full_name
        child.update!(first_name: first_name, last_name: last_name) unless mock
      end
    end
    Rails.logger.info "#{task}: #{involved_children_count} involved children updated"
    Rails.logger.info "#{task}: #{involved_children.count} involved children remaining"
  end
end
