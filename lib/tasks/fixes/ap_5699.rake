namespace :fixes do
  desc "Fixes for AP-5699"
  task :ap_5699, [:mock] => :environment do |_task, args|
    args.with_defaults(mock: "true")
    mock = args[:mock].to_s.downcase.strip != "false"

    if mock
      Rails.logger.info "----------------------------------------"
      Rails.logger.info "MOCK run enabled."
      Rails.logger.info "No actual changes will be made."
      Rails.logger.info "----------------------------------------"
    end

    Rails.logger.info "----------------------------------------"
    Rails.logger.info "Start of LLARNI"

    potter_derby_application_ids = %w[
      96c3f849-e2d5-4a71-b58f-8cddbb5a4f8a
      a6e1ad6a-0875-4b00-a0eb-21f22723f743
      1d2376e0-29a7-4e16-96ba-dbb4bafe252d
      7206e8ab-938f-4f95-9ce2-813989ea3568
    ]

    # Transfer applications from POTTER DERBY LTD office 0M434D to WACE MORGAN SOLICITORS office 0H036Y
    potter_derby_application_ids.each do |app_id|
      Rake::Task["ptr_migrations:laa_transfer_office"].execute(mock: mock, app_id: app_id, office_id: "c2d4f6df-0a06-4ade-b1c8-1bba1406a874")
    end

    # Delete the firm and offices of POTTER DERBY LTD
    Rake::Task["ptr_migrations:delete_firm_office"].execute(mock: mock, firm_id: "210ddca4-ad8c-4401-a981-1027efe7cf60")

    Rails.logger.info "End of LLARNI"
    Rails.logger.info "----------------------------------------"

    Rails.logger.info "----------------------------------------"
    Rails.logger.info "Start of DSYKES"

    # Transfer applications from CAROLE BURGHER SOLICITORS office 0M895E to BUTCHER & BARLOW LLP office 0L189A
    Rake::Task["ptr_migrations:laa_transfer_office"].execute(mock: mock, app_id: "6db37c7a-7350-4384-aa2d-c6a6ccfc22e9", office_id: "fe5dfac8-baa6-4a22-b0c9-681d97068508")

    # Delete the firm and offices of CAROLE BURGHER SOLICITORS
    Rake::Task["ptr_migrations:delete_firm_office"].execute(mock: mock, firm_id: "29bbd5ca-5820-4502-b74a-76b11e8bff64")

    Rails.logger.info "End of DSYKES"
    Rails.logger.info "----------------------------------------"

    Rails.logger.info "----------------------------------------"
    Rails.logger.info "Start of REFERRALS_FISHCO..."

    # Transfer provider EFERRALS@FISHCO.. from firm KEITH PARK SOLICITORS to HARPER ASHBY BOWLES LTD, Office: 0B869G
    Rake::Task["ptr_migrations:provider_transfer_firm"].execute(mock: mock, provider_id: "e4547a80-0621-44bf-a579-e7944ab5f947", firm_id: "142b3c71-87b9-4105-b607-2b14ffb34e7c")

    # Delete the firm and offices of KEITH PARK SOLICITORS
    Rake::Task["ptr_migrations:delete_firm_office"].execute(mock: mock, firm_id: "a4b2a3c3-9665-4723-989e-471effcfea3e")

    Rails.logger.info "End of REFERRALS_FISHCO..."
    Rails.logger.info "----------------------------------------"

    Rails.logger.info "----------------------------------------"
    Rails.logger.info "Start of HAZELBACON"

    # Transfer provider HAZELBACON from firm MCARAS to CANTER LEVIN & BERG LTD, Office: 5T620Z
    Rake::Task["ptr_migrations:provider_transfer_firm"].execute(mock: mock, provider_id: "03ec8aa6-56a4-494d-91e6-88d4974671db", firm_id: "02e2f920-c5fd-4e6c-9d6c-af1a16dfe7fc")

    # Delete the firm and offices of MCARAS
    Rake::Task["ptr_migrations:delete_firm_office"].execute(mock: mock, firm_id: "f16e1312-2118-4417-854d-316e504ebdfa")

    Rails.logger.info "End of HAZELBACON"
    Rails.logger.info "----------------------------------------"
  end
end
