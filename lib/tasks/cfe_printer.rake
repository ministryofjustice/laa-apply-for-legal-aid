namespace :cfe do
  desc 'display transactions sent to cfe for an application: rake cfe:display[L-ABC-123]'
  task :display, [:case_ref] => :environment do |_task, args|
    require_relative 'helpers/cfe_api_displayer'
    CfeApiDisplayer.new(args[:case_ref]).run
  end
end
