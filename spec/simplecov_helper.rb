require "active_support/inflector"
require "active_model/type"
require "simplecov"
module SimpleCovHelper
  def self.process_coverage
    SimpleCov.start do
      add_filter "config/initializers/"
      add_filter "spec/"
      add_filter "services/migration_helpers/"
      add_filter "config/environments/"

      minimum_coverage(line: 100)
      merge_timeout 3600
    end
  end

  def self.merge_coverage_results(base_dir: "./coverage_results", file_pattern: ".resultset*.json")
    SimpleCov.collate(Dir["#{base_dir}/#{file_pattern}"])
  end
end
