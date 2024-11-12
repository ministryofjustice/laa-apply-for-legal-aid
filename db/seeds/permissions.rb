class PermissionsPopulator
  ROLES = {
    # "example.permission.group" => "Description of example group",
    "special_children_act" => "Allow the firm to access SCA proceedings",
  }.freeze

  def self.run
    ROLES.each do |role, description|
      Permission.create!(role:, description:) if Permission.find_by(role:).nil?
    end
  end

  def self.tidy
    Permission.find_each do |permission|
      next if ROLES.key?(permission.role)

      Rails.logger.info "Removing #{permission.role} permission from database"
      permission.destroy!
    end
    ActorPermission.group(:permission_id).count.each do |permission_id, count|
      next if Permission.find(permission_id)
    rescue ActiveRecord::RecordNotFound
      Rails.logger.info "Delete #{count} ActorPermissions for #{permission_id}"
      ActorPermission.where(permission_id:).delete_all
    end
  end
end

PermissionsPopulator.run
PermissionsPopulator.tidy
