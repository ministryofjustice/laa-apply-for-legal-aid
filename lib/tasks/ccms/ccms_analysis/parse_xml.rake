namespace :ccms do
  desc 'parse CCMS payload'
  task parse_xml: :environment do
    require_relative 'helpers/ccms_payload_parser.rb'
    CCMS::PayloadParser.new.run
  end
end
