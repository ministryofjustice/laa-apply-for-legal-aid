namespace :portal do
  desc "Generate a script for new apply users"
  task :new_users, [:names] => :environment do |_task, args|
    Dir[Rails.root.join("lib/tasks/portal/*.rb")].each { |f| require f }

    return puts 'call with rake:portal:new_users\[pipe|separated|list|of|names\]' if args[:names].nil?

    @names = Portal::Collator.new(args[:names])
    puts "Could not match the following"
    puts @names&.unmatched&.map(&:display_name)
    return puts "No names matched, unable to output ldif file" if @names.matched.nil?

    script = Portal::GenerateScript.call(@names.matched)
    file_path = File.expand_path("./tmp/output.ldif")
    File.write(file_path, script)
    puts "Saved file as #{file_path}"
  end
end
