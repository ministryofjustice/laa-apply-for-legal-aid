# frozen_string_literal: true

include_file = File.join(Rails.root, 'helm_deploy', 'apply-for-legal-aid', 'whitelisted_users.yaml')
exclude_file = File.join(Rails.root, 'helm_deploy', 'apply-for-legal-aid', 'whitelisted_users_exclude.yaml')
unless Rails.env.development?
  Rails.configuration.x.application.whitelisted_users = YAML.load_file(include_file)
  Rails.configuration.x.application.whitelisted_users_excluding_test = Rails.configuration.x.application.whitelisted_users - YAML.load_file(exclude_file)
end
