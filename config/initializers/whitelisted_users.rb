# frozen_string_literal: true

white_listed_users = if Rails.env.production?
                       YAML.load_file(File.join(Rails.root, 'helm_deploy', 'apply-for-legal-aid', 'whitelisted_users.yaml'))
                     else
                       ['test1']
                     end

Rails.configuration.x.application.whitelisted_users = white_listed_users
