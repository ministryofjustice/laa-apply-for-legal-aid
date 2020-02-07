namespace :job do
  namespace :dashboard do
    desc 'Update stats on the dashboard'
    task :update, [:widgets] => :environment do |_task, args|
      widgets = args[:widgets].split
      widgets.each { |widget| Dashboard::UpdaterJob.perform_later(widget) }
    end

    namespace :update do
      desc 'updates all widgets'
      task all: :environment do
        widgets = Dir[Rails.root.join('app/models/dashboard/widget_data_providers/*.rb')]
        widgets.map { |f| File.basename(f, '.rb').camelize }.each do |widget_klass|
          Dashboard::UpdaterJob.perform_later(widget_klass)
        end
      end
    end
  end
end
