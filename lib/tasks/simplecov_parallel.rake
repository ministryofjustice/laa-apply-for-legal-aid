# frozen_string_literal: true

if ENV["CIRCLE_JOB"]
  namespace :simplecov do
    desc "Process coverage results"
    task process_coverage: :environment do
      require "simplecov"

      SimpleCov.collate Dir["./coverage_results/.resultset*.json"], "rails" do
        # TODO: Increase this back to 100 after AP-6125 is complete (as part of AP-6179)
        minimum_coverage line: 99
        refuse_coverage_drop :line, :branch
      end
    end
  end
end
