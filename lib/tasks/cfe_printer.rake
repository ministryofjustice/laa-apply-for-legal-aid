namespace :cfe do
  desc 'display transactions sent to cfe for an application: rake cfe:display[L-ABC-123]'
  task :display, [:application_ref] => :environment do |_task, args|
    if args[:application_ref].nil?
      puts '**** Missing application reference ****'
      puts "Specify application reference as follows: rake cfe:display[L-ABC-123]'"
      exit(1)
    end
    require_relative 'helpers/cfe_api_displayer'
    CfeApiDisplayer.new(args[:application_ref]).run
  end

  desc 'record cfe conversation as yaml so that it can be played back: rake cfe:record_payloads[L-ABC-123]'
  task :record_payloads, [:application_ref] => :environment do |_task, args|
    if args[:application_ref].nil?
      puts '**** Missing application reference ****'
      puts "Specify application reference as follows: rake cfe:display[L-ABC-123]'"
      exit(1)
    end
    require_relative 'helpers/cfe_payload_recorder'
    CfePayloadRecorder.call(args[:application_ref])
  end
end
