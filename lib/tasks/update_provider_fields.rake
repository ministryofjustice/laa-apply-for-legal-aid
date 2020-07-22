namespace :update_provider_fields do
  desc "Set existing providers to have portal access enabled"
  task update_portal_enabled: :environment do
    Provider.update_all portal_enabled: true
  end

  desc "Set existing providers contact_id"
  task update_contact_id: :environment do
    Provider.update_all contact_id: 999
  end
end
