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

  describe '#button_to_with_hidden_suffix' do
    let(:path) { 'test_path' }
    let(:klass) { 'test-class' }
    let(:visible_text) { 'visible link text' }
    let(:hidden_text) { 'hidden link text' }
    let(:method) { 'post' }
    let(:params) { { params: 'params' } }

    it 'returns the html for a styled button partly hidden from screen readers' do
      button = button_to_with_hidden_suffix(path: path, klass: klass, text: visible_text, method: method, params: params, suffix: hidden_text)
      expect(button).to eq '<form class="button_to" method="post" action="test_path"><button class="test-class" type="submit">visible link text' \
                           '<span class=\'govuk-visually-hidden\'> hidden link text</span></button><input type="hidden" name="params" value="params" /></form>'
    end

    context 'with no class provided' do
      it 'returns the html for an unstyled button partly hidden from screen readers' do
        button = button_to_with_hidden_suffix(path: path, text: visible_text, method: method, params: params, suffix: hidden_text)
        expect(button).to eq '<form class="button_to" method="post" action="test_path"><button type="submit">visible link text' \
                             '<span class=\'govuk-visually-hidden\'> hidden link text</span></button><input type="hidden" name="params" value="params" /></form>'
      end
    end
  end
end
