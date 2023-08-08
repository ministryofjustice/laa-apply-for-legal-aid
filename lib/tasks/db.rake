def build_postgres_url
  "postgres://#{ENV.fetch('POSTGRES_USER', '')}:#{ENV.fetch('POSTGRES_PASSWORD', '')}" \
    "@#{ENV.fetch('POSTGRES_HOST', '')}:5432/#{ENV.fetch('POSTGRES_DATABASE', '')}"
end

namespace :db do
  desc "Output anonymised DB as restore file"
  task export: :environment do
    raise(ArgumentError, "Cannot construct DB connection string") if build_postgres_url.length < 25

    command = "pg_dump #{build_postgres_url} --no-owner --no-privileges --no-password --exclude-table-data=scheduled_mailings \
                | pg_dump_anonymize -d db/anonymise/rules.rb > ./tmp/temp.sql"
    create_success = `#{command}`
    zip_success = `gzip -3 -f ./tmp/temp.sql`
    result_success = [create_success, zip_success].all?(&:empty?)
    puts result_success ? "Success" : "Error occurred"
  end

  desc "Restore anonymised DB to UAT instance"
  task import_to_uat: :environment do
    raise(ArgumentError, "Cannot construct DB connection string") if build_postgres_url.length < 25

    drop_existing_schema = "PGOPTIONS='--client_min_messages=warning' psql -q  #{build_postgres_url} -c 'drop schema public cascade'"
    create_new_schema = "PGOPTIONS='--client_min_messages=warning' psql -q  #{build_postgres_url} -c 'create schema public'"
    restore_anonymised_database = "psql #{build_postgres_url} -f ./tmp/anonymised_db.sql"

    `#{drop_existing_schema}`
    `#{create_new_schema}`
    `#{restore_anonymised_database}`

    list_of_users = Provider.last(10)
    list_of_users.each do |user|
      puts user.email
    end
  end
end
