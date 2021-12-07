desc 'Output anonymised DB as restore file with option to restore to UAT instance'
namespace :db do
  task export: :environment do
    raise(ArgumentError, 'Cannot construct DB connection string') if build_postgres_url.length < 25

    command = "pg_dump #{build_postgres_url} --no-owner --no-privileges --no-password | pg_dump_anonymize -d db/anonymise/rules.rb > ./tmp/temp.sql"
    create_success = `#{command}`
    zip_success = `gzip -3 -f ./tmp/temp.sql`
    result_success = [create_success, zip_success].all?(&:empty?)
    puts result_success ? 'Success' : 'Error occurred'
  end

  task import_to_uat: :environment do
    raise(ArgumentError, 'Cannot construct DB connection string') if build_postgres_url.length < 25

    drop_existing_schema = "psql #{build_postgres_url} -c 'drop schema public cascade'"
    create_new_schema = "psql #{build_postgres_url} -c 'create schema public'"
    restore_anonymised_database = "psql #{build_postgres_url} -f ./tmp/anonymised_db.sql"

    `#{drop_existing_schema}`
    `#{create_new_schema}`
    `#{restore_anonymised_database}`

    list_of_users = Provider.last(10)
    list_of_users.each do |user|
      puts user.email
    end
  end

  private

  def build_postgres_url
    "postgres://#{ENV.fetch('POSTGRES_USER', '')}:#{ENV.fetch('POSTGRES_PASSWORD', '')}" \
      "@#{ENV.fetch('POSTGRES_HOST', '')}:5432/#{ENV.fetch('POSTGRES_DATABASE', '')}"
  end
end
