AdminUser.find_or_create_by!(username: "apply_maintenance") do |admin_user|
  admin_user.email = "apply-for-civil-legal-aid@justice.gov.uk".freeze
end
