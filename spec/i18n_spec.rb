require 'i18n/tasks'
require 'rails_helper'

RSpec.describe 'I18n' do
  let(:i18n) { I18n::Tasks::BaseTask.new }
  let(:missing_keys) { i18n.missing_keys[locale] || I18n::Tasks::Data::Tree::Siblings.new }

  context 'English' do
    let(:locale) { 'en' }
    it 'does not have missing keys' do
      expect(missing_keys).to be_empty,
                              "Missing #{missing_keys.leaves.count} i18n keys, run `i18n-tasks missing' to show them"
    end
  end

  context 'Welsh' do
    let(:locale) { 'cy' }
    it 'does not have missing keys for the applicant journey' do
      missing_applicant_keys = []
      missing_keys.leaves.each do |leaf|
        missing_applicant_keys << leaf if leaf.data[:occurrences]&.first&.path&.include? '/citizen'
      end

      expect(missing_applicant_keys).to be_empty,
                                        "Missing #{missing_applicant_keys.count} i18n keys, run `i18n-tasks missing' to show them"
    end
  end
end
