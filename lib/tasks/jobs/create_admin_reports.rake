namespace :job do
  namespace :admin_reports do
    desc 'Upload admin reports'
    task upload: :environment do
      ReportsUploaderJob.perform_now
    end
  end
end
