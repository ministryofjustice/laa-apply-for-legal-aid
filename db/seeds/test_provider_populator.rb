class TestProviderPopulator
  TEST_FIRMS = {
    "Test & Co" => [823, %w[1T823E 2T823E 3T823E]],
    "Will-c & Co." => [910, %w[1W910I]],
    "Test-sch & Co." => [1137, %w[2T113E:1 3T113E:2 4T113E:3 5T113E:4]],
    "Test2 & Co." => [824, %w[1T824E:5 2T824E:6 3T824E:7 4T824E:8]],
    "Test3 & Co." => [825, %w[3T823E:9 2T825E:10 3T825E:11]],
    "Firm1 & Co." => [805, %w[1F805I:12 2F805I:13 3F805I:14 4F805I:15]],
    "Firm2 & Co." => [806, %w[2F805I:16 3F805I:17 4F805I:18]],
    "David Gray LLP" => [19_148, %w[0X395U:137570 2N078D:180736]],
    "Test firm for portal login" => [807, %w[9F805X:21 3X805Z:22]],
    "Ahern & Co." => [808, %w[9F808X:21 3X808Z:22]],
    "Sugarman & daughters" => [810, %w[6F810X:25 6X810Z:26]],
    "User Research Assoc." => [11_475, %w[4F808X:26 4X808Z:27]],
    "EDWARD HAYES LLP" => [19_537, %w[1T462U:85605]],
    "LAWRENCE & CO SOLICITORS CDS LLP" => [33_230, %w[0Q974B:85981]],
    "Rose & Co." => [809, %w[6F910X:28 7F320X:29]],
    "Keen & Co." => [101, %w[5F101X:30 7F101X:31]],
  }.freeze

  TEST_PROVIDERS = {
    "test1" => ["Test & Co", "test1@example.com", 100],
    "will-c" => ["Will-c & Co.", "william.clarke@justice.gov.uk", 101],
    "test-sch" => ["Test-sch & Co.", "apply-for-civil-legal-aid@justice.gov.uk", 102],
    "test2" => ["Test2 & Co.", "test2@example.com", 103],
    "test3" => ["Test3 & Co.", "really-really-long-email-address@example.com", 104],
    "firm1-user1" => ["Firm1 & Co.", "firm1-user1@example.com", 105],
    "firm1-user2" => ["Firm1 & Co.", "firm1-user2@example.com", 106],
    "firm2-user1" => ["Firm2 & Co.", "firm2-user1@example.com", 107],
    "ahernk" => ["Ahern & Co.", "katharine.ahern@justice.gov.uk", 109],
    "DGRAY-BRUCE-DAVID-GRA-LLP1" => ["David Gray LLP", "martin.ronan@example.com", 494_000, "mock-user-123", "51cdbbb4-75d2-48d0-aaac-fa67f013c50a"],
    "BENREID" => ["Test firm for portal login", "benreid@example.co.uk", 107],
    "HFITZSIMONS@EDWARDHAYES.CO.UK" => ["EDWARD HAYES LLP", "hfitzsimons@example.com", 2_453_773],
    "LHARRISON@TBILAW.CO.UK" => ["LAWRENCE & CO SOLICITORS CDS LLP", "LHARRISON@example.com", 954_474],
    "user-research" => ["User Research Assoc.", "user@resarch.com", 112],
    "rose" => ["Rose & Co.", "rose.azadkhan@justice.gov.uk", 114],
    "mkeen" => ["Keen & Co.", "mike.keen@justice.gov.uk", 115],
    "joel.sugarman@justice.gov.uk" => ["Sugarman & daughters", "joel.sugarman@justice.gov.uk", 109],
  }.freeze

  def self.call(name)
    data = TEST_PROVIDERS[name]
    return if data.nil?

    new.send(:populate_provider, name, data)
  end

  def run
    return if HostEnv.production?

    TEST_PROVIDERS.each { |username, details| populate_provider(username, details) }
  end

private

  def populate_provider(username, details)
    firm_name, email, ccms_contact_id, auth_subject_uid, silas_id = details
    firm = populate_firm(firm_name)
    return if Provider.exists?(username:)

    Provider.create!(
      username:,
      email:,
      ccms_contact_id:,
      firm:,
      offices: firm.offices,
      auth_provider: auth_subject_uid.present? ? "entra_id" : "",
      auth_subject_uid:,
      silas_id:,
    )
  end

  def populate_firm(firm_name)
    details = TEST_FIRMS.fetch(firm_name)
    ccms_id, office_code_ids = details
    firm = Firm.find_by(name: firm_name) || Firm.new(name: firm_name, ccms_id:)
    office_code_ids.each do |office_code_id|
      code, ccms_id = office_code_id.split(":")
      next if firm.offices.map(&:code).include?(code)

      firm.offices << Office.new(code:, ccms_id: ccms_id.to_s)
    end
    firm.save!
    firm
  end
end

TestProviderPopulator.new.run
