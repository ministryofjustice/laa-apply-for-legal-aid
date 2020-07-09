class ApplySystemRolesPopulator
  ROLES = {
    'application.passported.*' => 'Can create, edit, delete passported applications',
    'application.non_passported.*' => 'Can create, edit, delete non-passported applications'
  }.freeze

  def self.run
    ROLES.each do |role, description|
      ApplySystemRole.create(role: role, description: description) if ApplySystemRole.find_by(role: role).nil?
    end
  end
end

ApplySystemRolesPopulator.run
