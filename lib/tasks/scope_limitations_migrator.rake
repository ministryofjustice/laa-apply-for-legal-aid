namespace :scopes do
  desc 'Migrates scope limiations from being attached to application to beinga attached to application-proceeding type'
  task migrate: :environment do
    require Rails.root.join('lib/tasks/helpers/scope_limitations_migrator')
    ScopeLimitationsMigrator.call
  end
end
