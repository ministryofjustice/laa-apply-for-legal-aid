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

  task import_to_dev: :environment do
    command_one = 'psql -q -d apply_for_legal_aid_dev -c "drop schema public cascade"'
    command_two = 'psql -q -d apply_for_legal_aid_dev -c "create schema public"'
    command_three = 'psql -q -P pager=off -d apply_for_legal_aid_dev -f ./tmp/production.anon.sql'
    `#{command_one}`
    `#{command_two}`
    `#{command_three}`
  end

  task import_to_uat: :environment do
    raise(ArgumentError, 'Cannot construct DB connection string') if build_postgres_url.length < 25

    $stdin.binmode
    db_file = Tempfile.new('temp_file_prefix', Rails.root.join('tmp'))
    db_file.write($stdin.read)
    db_file.close

    command_one = "psql #{build_postgres_url} -c 'drop schema public cascade'"
    command_two = "psql #{build_postgres_url} -c 'create schema public'"
    command_three = "psql #{build_postgres_url} -f < db_file"
    # command_three = "psql #{build_postgres_url} -f < #{db_file}"

    puts 'starting the rake task'
    `#{command_one}`
    `#{command_two}`
    `#{command_three}`

    puts db_file.path
    db_file.unlink
  end

  private

  def build_postgres_url
    "postgres://#{ENV.fetch('POSTGRES_USER', '')}:#{ENV.fetch('POSTGRES_PASSWORD', '')}" \
      "@#{ENV.fetch('POSTGRES_HOST', '')}:5432/#{ENV.fetch('POSTGRES_DATABASE', '')}"
  end
end
