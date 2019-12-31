# frozen_string_literal: true

file_name = File.join(Rails.root, 'helm_deploy', 'apply-for-legal-aid', 'whitelisted_users.yaml')
Rails.configuration.x.application.whitelisted_users = YAML.load_file(file_name) unless Rails.env.development?
