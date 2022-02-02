# frozen_string_literal: true

require 'active_support/inflector'
require 'active_model/type'
require 'simplecov'
require 'parallel_tests'

module SimpleCovHelper
  def self.process_coverage
    skip_check_coverage = ActiveModel::Type::Boolean.new.cast(
      ENV.fetch('SKIP_COVERAGE_CHECK', 'false')
    )

    SimpleCov.start 'rails' do
      enable_coverage :branch
      coverage_criterion :branch

      add_filter '/config/'
      add_filter '/spec/'
      add_filter '/vendor/'

      Dir['app/*'].each do |dir|
        add_group File.basename(dir).humanize, dir
      end

      minimum_coverage(line: 100, branch: 87.89) unless skip_check_coverage
      merge_timeout 3600
    end
  end

  def self.merge_coverage_results(base_dir: './coverage_results', file_pattern: '.resultset*.json')
    SimpleCov.collate(Dir["#{base_dir}/#{file_pattern}"])
  end
end
