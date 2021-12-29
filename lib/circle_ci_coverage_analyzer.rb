require 'json'


# This class is useful for debugging why coverage is not 100% on Circle-CI
# A line to run this is included in the .circle/config.yml, however, if coverage is incomplete
# the line:
#
#     SimpleCov.minimum_coverage 100
#
# must be changed to a value less than 100 in order to get this script to run after the tests.
#
# rubocop:disable Rails/Output
class CircleCICoverageAnalyzer
  def self.call(filename)
    new(filename).call
  end

  def initialize(filename)
    json = File.read(filename)
    @data = JSON.parse(json)
  end

  def call
    puts "Coverage percentage: #{coverage_percentage}"
    return if coverage_percentage == 100

    print_missing
  end

  private

  def coverage_percentage
    @coverage_percentage ||= @data['covered_percent']
  end

  def print_missing
    @data['source_files'].each { |source_file| analyze_source_file(source_file) }
  end

  def analyze_source_file(source_file)
    return if source_file['covered_percent'] == 100

    puts "#{source_file['name']} :: #{source_file['covered_percent']}%"
  end
end

CircleCICoverageAnalyzer.call(ARGV.first)
# rubocop:enable Rails/Output
