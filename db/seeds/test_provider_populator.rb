class TestProviderPopulator
  TEST_FIRMS = {
    'Test & Co' => [823, %w[1T823E 2T823E 3T823E]],
    'Will-c & Co.' => [910, ['1W910I']],
    'Test-sch & Co.' => [1137, %w[2T113E:1 3T113E:2 4T113E:3 5T113E:4]],
    'Test2 & Co.' => [824, %w[1T824E:5 2T824E:6 3T824E:7 4T824E:8]],
    'Test3 & Co.' => [825, %w[3T823E:9 2T825E:10 3T825E:11]],
    'Firm1 & Co.' => [805, %w[1F805I:12 2F805I:13 3F805I:14 4F805I:15]],
    'Firm2 & Co.' => [806, %w[2F805I:16 3F805I:17 4F805I:18]],
    'Richards & Co.' => [555, %w[1S555R:19 2S555R:20]],
    'David Gray LLP' => [19_148, ['0B721W:137570']],
    'Test firm for portal login' => [807, %w[9F805X:21 3X805Z:22]]
  }.freeze

  TEST_PROVIDERS = {
    'test1' => ['Test & Co', 'test1@example.com', 100, 370],
    'will-c' => ['Will-c & Co.', 'william.clarke@digital.justice.gov.uk', 101, 424],
    'test-sch' => ['Test-sch & Co.', 'apply-for-legal-aid@digital.justice.gov.uk', 102, 587],
    'test2' => ['Test2 & Co.', 'test2@example.com', 103, 588],
    'test3' => ['Test3 & Co.', 'really-really-long-email-address@example.com', 104, 589],
    'firm1-user1' => ['Firm1 & Co.', 'firm1-user1@example.com', 105, 590],
    'firm1-user2' => ['Firm1 & Co.', 'firm1-user2@example.com', 106, 591],
    'firm2-user1' => ['Firm2 & Co.', 'firm2-user1@example.com', 107, 592],
    'sr' => ['Richards & Co.', 'stephen.richards@digital.justice.gov.uk', 108, 593],
    'MARTIN.RONAN@DAVIDGRAY.CO.UK' => ['David Gray LLP', 'martin.ronan@example.com', 494_000, 5027],
    'BENREID' => ['Test firm for portal login', 'benreid@example.co.uk', 107, 592]
  }.freeze

  def run
    return if HostEnv.production?

    TEST_PROVIDERS.each { |username, details| populate_provider(username, details) }
    populate_firm_permissions
  end

  private

  def populate_firm_permissions # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    passported_permission = Permission.find_by(role: 'application.passported.*')
    non_passported_permission = Permission.find_by(role: 'application.non_passported.*')
    Firm.all.each do |firm|
      firm.permissions << passported_permission unless firm.permissions.map(&:role).include?('application.passported.*')
      firm.permissions << non_passported_permission unless firm.permissions.map(&:role).include?('application.non_passported.*')
      firm.save!
    end
  end

  def populate_provider(username, details)
    firm_name, email, contact_id = details
    firm = populate_firm(firm_name)
    return if Provider.exists?(username: username)

    Provider.create!(
      username: username,
      email: email,
      contact_id: contact_id,
      firm: firm,
      offices: firm.offices
    )
  end

  def populate_firm(firm_name)
    details = TEST_FIRMS.fetch(firm_name)
    ccms_id, office_code_ids = details
    firm = Firm.find_by(name: firm_name) || Firm.new(name: firm_name, ccms_id: ccms_id)
    office_code_ids.each do |office_code_id|
      code, ccms_id = office_code_id.split(':')
      next if firm.offices.map(&:code).include?(code)

      firm.offices << Office.new(code: code, ccms_id: ccms_id.to_s)
    end
    firm.save!
    firm
  end
end

TestProviderPopulator.new.run
