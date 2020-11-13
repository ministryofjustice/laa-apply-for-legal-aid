class PermissionsUpdater
  def initialize
    @passported = Permission.find_by(role: 'application.passported.*')
    @non_passported = Permission.find_by(role: 'application.non_passported.*')
  end

  def run
    Firm.all.each { |firm| update_permissions(firm) }
  end

  private

  def update_permissions(firm)
    firm.permissions << @passported unless firm.permissions.include?(@passported)
    firm.permissions << @non_passported unless firm.permissions.include?(@non_passported)
    firm.save!
  end
end
