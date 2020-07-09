class PermissionsPopulator
  ROLES = {
    'application.passported.*' => 'Can create, edit, delete passported applications',
    'application.non_passported.*' => 'Can create, edit, delete non-passported applications'
  }.freeze

  def self.run
    ROLES.each do |role, description|
      Permission.create(role: role, description: description) if Permission.find_by(role: role).nil?
    end
  end
end

PermissionsPopulator.run
