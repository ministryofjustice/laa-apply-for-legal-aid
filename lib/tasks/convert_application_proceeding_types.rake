namespace :application_proceeding_types do
  desc 'Convert application_proceeding_types into proceedings'
  task convert: :environment do
    raise 'Proceedings records already exist' if Proceeding.count.positive?

    apt_count = ApplicationProceedingType.count
    puts "#{apt_count} application_proceeding_type records to convert"

    ProceedingsConverter.new.call

    proceedings_count = Proceeding.count
    puts "#{proceedings_count} proceeding records created"

    puts 'All application_proceeding_type records converted succesfully' if proceedings_count.eql? apt_count
    puts 'WARNING: Too many proceedings records created' if proceedings_count > apt_count
    puts 'WARNING: Not enough proceedings records created' if proceedings_count < apt_count
  end
end
