namespace :job do
  namespace :dashboard do
    desc 'Update stats on the dashboard'
    task :update, [:widget] => :environment do |_task, args|
      widget = args[:widget]
      Dashboard::UpdaterJob.perform_later(widget)
    end
  end
end
