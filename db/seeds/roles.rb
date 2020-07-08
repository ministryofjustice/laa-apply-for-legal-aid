class RolePopulator
  ROLES = {
    'application.passported.*' => 'Can create, edit, delete passported applications',
    'application.non_passported.*' => 'Can create, edit, delete non-passported applications'
  }.freeze

  def self.run
    ROLES.each do |role, description|
      Role.create(role: role, description: description) if Role.find_by(role: role).nil?
    end
  end
end

RolePopulator.run
