#!/usr/bin/env ruby
require 'json'
require 'http'

PREFIX = 'apply-'.freeze
REPO_NAME = 'laa-apply-for-legal-aid'.freeze

response = HTTP.get("https://api.github.com/repos/ministryofjustice/#{REPO_NAME}/pulls")
open_pr = JSON.parse(response.body, symbolize_names: true).map { |pr| pr[:head][:ref].gsub(/[\(\)\[\]_\/\s\.]/, '-') }

uat_releases=JSON.parse(`helm list --tiller-namespace=${KUBE_ENV_UAT_NAMESPACE} --all --output json`, symbolize_names: true)
active_namespaces = uat_releases[:Releases].map { |helm| helm[:Name] } - ["#{PREFIX}master"]

active_namespaces.each do |environment|
  pr_still_exists = open_pr.map { |name| name.include?(environment.delete_prefix(PREFIX)) }.any?
  result =if pr_still_exists
            "PR still open, retaining #{environment}"
          else
            `helm --tiller-namespace=${KUBE_ENV_UAT_NAMESPACE} delete #{environment} --dry-run`
          end
  puts result
end
