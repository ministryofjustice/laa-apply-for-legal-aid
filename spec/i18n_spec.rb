require "i18n/tasks"
require "rails_helper"

RSpec.describe "I18n", :i18n do
  let(:i18n) { I18n::Tasks::BaseTask.new }
  let(:missing_keys) { i18n.missing_keys[locale] || I18n::Tasks::Data::Tree::Siblings.new }

  context "with English" do
    let(:locale) { "en" }

    it "does not have missing keys" do
      expect(missing_keys).to be_empty,
                              "Missing #{missing_keys.leaves.count} i18n keys, run `i18n-tasks missing en' to show them"
    end
  end

  context "with Welsh" do
    let(:locale) { "cy" }
    let(:welsh_paths) { ["/accessibility_statement", "/citizen", "/contact", "/error", "/feedback", "/privacy_policy"] }

    it "does not have missing keys for the applicant journey" do
      missing_applicant_keys = []
      missing_keys.leaves.each do |leaf|
        missing_applicant_keys << leaf if welsh_paths.any? do |path|
          leaf.data[:occurrences].first.path.include? "views#{path}" if leaf.data[:occurrences]
        end
      end
      expect(missing_applicant_keys).to be_empty, print_missing_keys(missing_applicant_keys)
    end
  end

  def print_missing_keys(missing_applicant_keys)
    key_details = gather_missing_details(missing_applicant_keys)
    max_key_length = key_details.keys.map(&:length).max
    max_location_length = key_details.values.map(&:length).max
    format_string = "%<key>-#{max_key_length}s %<location>s"

    output = sprintf "\nTranslation keys missing for locale #{locale.inspect}".red
    output += "\n#{sprintf(format_string, key: 'key', location: 'location').red}"
    output += "\n#{sprintf(format_string, key: ('=' * max_key_length), location: ('=' * max_location_length)).red}"
    key_details.each do |key, location|
      output += "\n#{sprintf(format_string, key:, location:).red}"
    end
    output
  end

  def gather_missing_details(missing_applicant_keys)
    details = {}
    missing_applicant_keys.each do |leaf|
      leaf.data[:occurrences].each do |occ|
        details[leaf.full_key] = occ.path
      end
    end
    details
  end
end
