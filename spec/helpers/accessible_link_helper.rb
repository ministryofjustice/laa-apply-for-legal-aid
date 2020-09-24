require 'rails_helper'

RSpec.describe AccessibleLinkHelper, type: :helper do
  describe '#link_to_with_hidden_suffix' do
    let(:path) { 'test_path' }
    let(:klass) { 'test-class' }
    let(:visible_text) { 'visible link text' }
    let(:hidden_text) { 'hidden link text' }

    it 'returns the html for a link partly hidden from screen readers' do
      link = link_to_with_hidden_suffix(path: path, klass: klass, text: visible_text, suffix: hidden_text)
      expect(link).to eq "<a class=\"test-class\" href=\"test_path\">visible link text<span class='govuk-visually-hidden'> hidden link text</span></a>"
    end

    context 'with no class provided' do
      it 'returns the html for a link partly hidden from screen readers' do
        link = link_to_with_hidden_suffix(path: path, text: visible_text, suffix: hidden_text)
        expect(link).to eq "<a href=\"test_path\">visible link text<span class='govuk-visually-hidden'> hidden link text</span></a>"
      end
    end
  end
end
