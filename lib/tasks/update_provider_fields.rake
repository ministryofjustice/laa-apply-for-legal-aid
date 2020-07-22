namespace :update_provider_fields do
  desc 'Set existing providers to have portal access enabled'
  task update_portal_enabled: :environment do
    Provider.update_all portal_enabled: true, updated_at: Time.now
  end

  desc 'Set existing providers contact_id'
  task update_contact_id: :environment do
    Provider.find_each do |user|
      id = user.details_response['contacts']

      # this is the version for localhost/uat as we prepend a number to the username

      id.each do |contact|
        user.update(contact_id: id[0]['id']) if contact['name'] == "#{user.username}-1".capitalize
      end

      # this is the version for prod makes usernames downcase to ensure matches

      # id.each do |contact|
      #   if contact['name'].downcase == user.username.downcase
      #     user.update(contact_id: id[0]['id'])
      #   end
      # end
    end
  end
end
