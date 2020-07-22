namespace :update_provider_fields do
  desc "Set existing providers to have portal access enabled"
  task update_portal_enabled: :environment do
    Provider.update_all portal_enabled: true, updated_at: Time.now
  end

  desc "Set existing providers contact_id"
  task update_contact_id: :environment do
    # js = Provider.last.details_response['contacts']
    # cc_id = js.find{|contact| contact['name'] == 'Test2-2' }
    # Provider.update test_json: cc_id['id']

    # Provider.where(username: 'will-c').each do |q|
    #   q.update(test_json: 987)
    # end

    # Provider.all.each do |user|
    #   ap user.details_response['contacts'].where user.details_response['contacts']['name'] == user.username
    #   user.update(test_json: user.details_response['contacts'][0]['id'])
    # end

    Provider.find_each do |user|
      ap 'capitalize name'
      ap "#{user.username}-1".capitalize

      id = user.details_response['contacts']

      id.each do |contact|
        puts contact
        if contact['name'] == "#{user.username}-1".capitalize
          puts contact['name']
          puts user.username
          user.update(test_json: id[0]['id'] )
        else
          puts "No Match found"
        end
      end

      # ap 22222
      # user.update(test_json: user.details_response['contacts'][0]['id'])
    end
  end
end

