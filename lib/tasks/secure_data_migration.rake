namespace :secure_data_migration do
  desc "Temporary task to migrate SecureData TrueLayer tokens to encrypted attributes"
  task :true_layer_tokens, %i[commit sample] => :environment do |_task, args|
    args = args.with_defaults(commit: "false", sample: nil)

    # `true_layer_secure_data_id` is a string rather than a UUID, so we can't use `joins`
    applicants = if args[:sample]
                   Applicant.where.not(true_layer_secure_data_id: [nil, ""]).limit(args[:sample].to_i)
                 else
                   Applicant.where.not(true_layer_secure_data_id: [nil, ""])
                 end

    puts "Found #{applicants.count} Applicants with TrueLayer token data to migrate"
    puts "Migrating SecureData TrueLayer tokens in batches of 50..."

    applicants.in_batches(of: 50).each_with_index do |batch, batch_index|
      batch.each do |applicant|
        token_data = applicant.true_layer_secure_data.retrieve

        puts "Found Applicant #{applicant.id} with token ...#{token_data[:token].last(5)}"

        next unless args[:commit] == "true"

        data_to_encrypt = {
          token: token_data[:token],
          expires_at: token_data[:expires],
        }

        applicant.update!(encrypted_true_layer_token: data_to_encrypt)

        puts "Updated Applicant #{applicant.id}"
      end

      next unless args[:commit] == "true"

      updated = [(batch_index + 1) * 50, applicants.count].min
      puts "Updated #{updated} of #{applicants.count} Applicants"
    end
  end
end
