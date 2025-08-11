# frozen_string_literal: true

if ENV["CIRCLE_JOB"]
  namespace :simplecov do
    desc "Process coverage results"
    task process_coverage: :environment do
      require "simplecov"

      SimpleCov.collate Dir["./coverage_results/.resultset*.json"], "rails" do
        minimum_coverage line: 100
        refuse_coverage_drop :line, :branch
      end
    end
  end
end
