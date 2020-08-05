class TestProviderPopulator
  TEST_FIRMS = {
    'Test & Co' => [823, %w[1T823E 2T823E 3T823E]],
    'Will-c & Co.' => [910, ['1W910I']],
    'Test-sch & Co.' => [1137, %w[2T113E 3T113E 4T113E 5T113E]],
    'Test2 & Co.' => [824, %w[1T824E 2T824E 3T824E 4T824E]],
    'Test3 & Co.' => [825, %w[3T823E 2T825E 3T825E]],
    'Firm1 & Co.' => [805, %w[1F805I 2F805I 3F805I 4F805I]],
    'Firm2 & Co.' => [806, %w[2F805I 3F805I 4F805I]],
    'Richards & Co.' => [555, %w[1S555R 2S555R]],
    'David Gray LLP' => [19_148, ['0B721W']]
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
    'MARTIN.RONAN@DAVIDGRAY.CO.UK' => ['David Gray LLP', 'martin.ronan@example.com', 494_000, 5027]
  }.freeze

  def run
    return if HostEnv.production?

    TEST_PROVIDERS.each { |username, details| populate_provider(username, details) }
    populate_firm_permissions
  end

  private

  def populate_firm_permissions
    passported_permission = Permission.find_by(role: 'application.passported.*')
    non_passported_permission = Permission.find_by(role: 'application.non_passported.*')
    Firm.all.each do |f|
      f.permissions << passported_permission
      f.save!
    end

    %w[test1 sr MARTIN.RONAN@DAVIDGRAY.CO.UK].each do |firm_name|
      firm = Provider.find_by(username: firm_name).firm
      firm.permissions << non_passported_permission
      firm.save!
    end
  end

  def populate_provider(username, details)
    firm_name, email, contact_id, user_login_id = details
    firm = populate_firm(firm_name)
    return if Provider.exists?(username: username)

    Provider.create!(
      username: username,
      email: email,
      contact_id: contact_id,
      user_login_id: user_login_id,
      firm: firm,
      offices: firm.offices
    )
  end

  def populate_firm(firm_name)
    details = TEST_FIRMS.fetch(firm_name)
    ccms_id, office_codes = details
    firm = Firm.find_by(name: firm_name) || Firm.new(name: firm_name, ccms_id: ccms_id)
    office_codes.each do |code|
      next if firm.offices.map(&:code).include?(code)

      firm.offices << Office.new(code: code, ccms_id: rand(1..9999).to_s)
    end
    firm.save!
    firm
  end
end

TestProviderPopulator.new.run
