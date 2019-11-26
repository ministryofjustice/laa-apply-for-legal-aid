# frozen_string_literal: true

Rails.configuration.x.application.whitelisted_users = YAML.load_file(File.join(Rails.root, 'helm_deploy', 'apply-for-legal-aid', 'whitelisted_users.yaml'))
