namespace :update_provider_fields do
  desc 'Set existing providers to have portal access enabled'
  task update_portal_enabled: :environment do
    ActiveRecord::Base.transaction do
      pc = Provider.all.count
      puts "Total number of providers #{pc}"
      Provider.update_all portal_enabled: true, updated_at: Time.now
      pcount = Provider.where(portal_enabled: false).count
      puts "After task users with portal_enabled set to False count is #{pcount}"
    end
  end

  desc 'Set existing providers contact_id'
  task update_contact_id: :environment do
    ActiveRecord::Base.transaction do
      pc = Provider.all.count
      puts "Total number of providers #{pc}"
      Provider.find_each do |user|
        id = user.details_response['contacts']
        id.each do |contact|
          user.update!(contact_id: id[0]['id']) if contact['name'] == user.username
        end
      end
      pcnil = Provider.where(contact_id: nil).count
      pcnotnil = Provider.where.not(contact_id: nil).count
      puts "After task, users with empty contact_id is #{pcnil}"
      puts "After task, users with contact_id is #{pcnotnil}"
    end
  end
end
