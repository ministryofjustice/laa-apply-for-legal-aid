namespace :coverage do
  desc 'Collate test reports from CircleCI'
  task report: :environment do
    require 'simplecov'

    SimpleCov.collate Dir['coverage_results/.resultset-*.json'], 'rails' do
      formatter SimpleCov::Formatter::MultiFormatter.new(
        [
          SimpleCov::Formatter::SimpleFormatter,
          SimpleCov::Formatter::HTMLFormatter
        ]
      )
    end
  end
end
