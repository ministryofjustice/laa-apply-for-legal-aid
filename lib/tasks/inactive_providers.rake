namespace :inactive_providers do
  desc 'List inactive providers'
  task list: :environment do
    CSV.open(Rails.root.join('tmp/inactive_providers.csv'), 'wb') do |csv|
      csv << %w[
        id
        email
        last_sign_in_at
        current_sign_in_at
        created_at
        updated_at
        portal_enabled
      ]
      inactive_providers = Provider.where('current_sign_in_at < ? OR (current_sign_in_at IS NULL AND created_at < ?)', 6.months.ago.to_date, 6.months.ago.to_date)
      inactive_providers.each do |inactive_provider|
        csv << [
          inactive_provider.id,
          inactive_provider.email,
          inactive_provider.last_sign_in_at,
          inactive_provider.current_sign_in_at,
          inactive_provider.created_at,
          inactive_provider.updated_at,
          inactive_provider.portal_enabled
        ]
      end
      puts "Listed #{inactive_providers.count} inactive providers in tmp/inactive_providers.csv"
    end
  end

  desc 'Deactivate inactive providers'
  task deactivate: :environment do
    inactive_providers = Provider.where('current_sign_in_at < ? OR (current_sign_in_at IS NULL AND created_at < ?)', 6.months.ago.to_date, 6.months.ago.to_date)
    inactive_providers.each do |inactive_provider|
      inactive_provider.update!(portal_enabled: false)
    end
    puts "Deactivated #{inactive_providers.count} inactive providers"
  end
end
