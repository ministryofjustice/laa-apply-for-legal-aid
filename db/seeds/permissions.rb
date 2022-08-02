class PermissionsPopulator
  ROLES = {
    "application.passported.*" => "Can create, edit, delete passported applications",
    "application.non_passported.*" => "Can create, edit, delete non-passported applications",
    "application.non_passported.employment.*" => "Can create, edit, delete employment applications",
    "application.non_passported.bank_statement_upload.*" => "Can upload bank statements",
    "application.full_section_8.*" => "Can use full set of section 8 proceedings",
  }.freeze

  def self.run
    ROLES.each do |role, description|
      Permission.create(role:, description:) if Permission.find_by(role:).nil?
    end
  end
end

PermissionsPopulator.run
