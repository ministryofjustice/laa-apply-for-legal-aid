# frozen_string_literal: true

require_relative '../../spec/simplecov_helper'
namespace :simplecov do
  desc 'Merge coverage results'
  task merge_coverage_results: :environment do
    SimpleCovHelper.merge_coverage_results
  end

  desc 'Process coverage results'
  task process_coverage: :environment do
    SimpleCovHelper.process_coverage
  end
end
