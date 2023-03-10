class PermissionsPopulator
  ROLES = {
    "application.full_section_8.*" => "Can use full set of section 8 proceedings",
  }.freeze

  def self.run
    ROLES.each do |role, description|
      Permission.create(role:, description:) if Permission.find_by(role:).nil?
    end
  end

  def self.tidy
    Permission.all.each do |permission|
      next if ROLES.key?(permission.role)

      Rails.logger.info "Removing #{permission.role} permission from database"
      permission.destroy!
    end
  end
end

PermissionsPopulator.run
PermissionsPopulator.tidy
