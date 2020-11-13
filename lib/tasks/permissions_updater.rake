namespace :temp do
  task permissions: :environment do
    require Rails.root.join('lib/tasks/helpers/permissions_updater')
    PermissionsUpdater.new.run
  end
end
