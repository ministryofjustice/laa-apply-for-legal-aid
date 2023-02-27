namespace :secure_data_migration do
  desc "Temporary task to migrate SecureData citizen url IDs to access tokens"
  task :citizen_urls, %i[commit sample] => :environment do |_task, args|
    args = args.with_defaults(commit: "false", sample: nil)

    secure_data = if args[:sample]
                    SecureData.limit(args[:sample].to_i)
                  else
                    SecureData.all
                  end

    puts "There are #{Citizen::AccessToken.count} access tokens"
    puts "--------------------------------------------------"

    puts "Migrating SecureData citizen url IDs to access tokens"
    puts "--------------------------------------------------"

    access_token_count = 0
    not_found_application_count = 0

    secure_data.in_batches(of: 100) do |batch|
      batch_token_count = 0

      # Decrypt the data
      decrypted_data = batch.map { { id: _1.id, data: _1.retrieve } }

      # Select only the citizen url data
      decrypted_data.select! { _1.fetch(:data).key?(:legal_aid_application) }

      puts "Found #{decrypted_data.count} citizen url IDs out of #{batch.count} SecureData records"
      puts "--------------------------------------------------"

      decrypted_data.each do |citizen_url_data|
        secure_data_id = citizen_url_data[:id]
        secure_data_expired_at = Date.parse(citizen_url_data[:data][:expired_at])
        legal_aid_application_id = citizen_url_data[:data][:legal_aid_application]["id"]

        begin
          legal_aid_application = LegalAidApplication.find(legal_aid_application_id)

          next unless args[:commit] == "true"

          # Only create a new access token if one doesn't already exist
          access_token = Citizen::AccessToken.find_or_initialize_by(token: secure_data_id)

          unless access_token.persisted?
            access_token.assign_attributes(
              # Citizen access tokens expire on a date, SecureData tokens expired after 23:59:59 on a given day
              expires_on: secure_data_expired_at.days_since(1),
              legal_aid_application:,
            )
            access_token.save!(validate: false)
            access_token_count += 1
            batch_token_count += 1
          end
        rescue ActiveRecord::RecordNotFound
          puts "Could not find legal aid application #{legal_aid_application_id} for SecureData #{secure_data_id}"
          puts "--------------------------------------------------"
          not_found_application_count += 1
        end
      end

      puts "Migrated #{batch_token_count} citizen url IDs to access tokens"
      puts "--------------------------------------------------"
    end

    puts "Migrated #{access_token_count} citizen url IDs to access tokens"
    puts "--------------------------------------------------"

    puts "Finished migrating SecureData citizen url IDs to access tokens"
    puts "--------------------------------------------------"

    puts "Could not find #{not_found_application_count} legal aid applications"
    puts "--------------------------------------------------"

    puts "There are #{Citizen::AccessToken.count} access tokens"
    puts "--------------------------------------------------"
  end
end
