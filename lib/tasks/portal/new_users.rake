namespace :portal do
  desc "Generate a script for new apply users"
  task :new_users, [:names] => :environment do |_task, args|
    Rails.root.glob("lib/tasks/portal/*.rb").each { |f| require f }

    if args[:names].nil?
      Rails.logger.info "call with rake:portal:new_users[pipe|separated|list|of|names]"
      next
    end

    @names = Portal::Collator.new(args[:names])
    Rails.logger.info "Could not match the following"
    Rails.logger.info @names&.unmatched&.map(&:display_name)

    if @names.matched.nil?
      Rails.logger.info "No names matched, unable to output ldif file"
      next
    end

    script = Portal::GenerateScript.call(@names.matched)
    file_path = File.expand_path("./tmp/output.ldif")
    File.write(file_path, script)
    Rails.logger.info "Saved file as #{file_path}"
  end
end
