desc 'Testing emails'
task smoke_test: :environment do
  SmokeTest::TestEmails.call
end
