if Rails.configuration.x.admin_portal.password.present?
  AdminUser.find_or_create_by(username: 'apply_maintenance') do |admin_user|
    admin_user.password = Rails.configuration.x.admin_portal.password
    admin_user.email = 'apply-for-legal-aid@digital.justice.gov.uk'.freeze
  end
end
