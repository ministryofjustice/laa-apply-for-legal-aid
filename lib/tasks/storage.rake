namespace :storage do
  desc 'Clears the storage directory'
  task clear: :environment do
    raise 'Only available in development environment' unless Rails.env.development?

    system "rm -rf #{Rails.root.join('storage')}"
    Attachment.all.map(&:destroy)
  end
end
