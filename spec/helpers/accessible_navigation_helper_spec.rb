require 'rails_helper'

RSpec.describe AccessibleNavigationHelper, type: :helper do
  describe '#link_to_accessible' do
    let(:name) { 'Start now' }
    let(:path) { 'test_path' }
    let(:html_options) { { class: 'gov_link' } }

    context 'with html options' do
      it 'returns the html for a link with an aria-label, title attribute and other properties' do
        link = link_to_accessible(name, path, html_options)
        expect(link).to eq '<a class="gov_link" title="Start now" aria-label="Start now" href="test_path">Start now</a>'
      end
    end

    context 'with suffix' do
      let(:html_options) { { class: 'gov_link', suffix: 'Application' } }

      it 'returns with aria-label and title containing label name and suffix' do
        link = link_to_accessible(name, path, html_options)
        str = '<a class="gov_link" suffix="Application" title="Start now Application" aria-label="Start now Application" href="test_path">Start now</a>'
        expect(link).to eq str
      end
    end

    context 'with no html options' do
      it 'returns the html for a link with an aria-label and title attribute' do
        link = link_to_accessible(name, path)
        expect(link).to eq '<a title="Start now" aria-label="Start now" href="test_path">Start now</a>'
      end
    end

    context 'with block only' do
      it 'returns the html for a link without an aria-label and title attribute' do
        link = link_to_accessible(path) { 'Start now' }
        expect(link).to eq '<a href="test_path">Start now</a>'
      end
    end
  end

  describe '#button_to_accessible' do
    let(:name) { 'Start now' }
    let(:path) { 'test_path' }
    let(:html_options) { { class: 'gov_button' } }

    context 'with html options' do
      it 'returns the html for a button with an aria-label, title attribute and other properties' do
        str = '<form class="button_to" method="post" action="test_path">'
        str << '<input class="gov_button" title="Start now" aria-label="Start now" type="submit" value="Start now" /></form>'
        button = button_to_accessible(name, path, html_options)
        expect(button).to eq str
      end
    end

    context 'with no html options' do
      it 'returns the html for a button with an aria-label and title attribute' do
        str = '<form class="button_to" method="post" action="test_path">'
        str << '<input title="Start now" aria-label="Start now" type="submit" value="Start now" /></form>'
        button = button_to_accessible(name, path)
        expect(button).to eq str
      end
    end

    context 'with suffix' do
      let(:html_options) { { class: 'gov_button', suffix: 'Application' } }

      it 'returns with aria-label and title containing label name and suffix' do
        button = button_to_accessible(name, path, html_options)
        str = '<form class="button_to" method="post" action="test_path">'
        str << '<input class="gov_button" suffix="Application" title="Start now Application" aria-label="Start now Application" type="submit" value="Start now" /></form>'
        expect(button).to eq str
      end
    end

    context 'with block only' do
      it 'returns the html for a button without an aria-label and title attribute' do
        button = button_to_accessible(path) { 'Start now' }
        expect(button).to eq '<form class="button_to" method="post" action="test_path"><button type="submit">Start now</button></form>'
      end
    end
  end

  describe '#set_accessible_properties' do
    context 'standard html label' do
      it 'sets aria-labels and titles using the label name provided' do
        options = set_accessible_properties('name', {})
        expect(options).to eq({ aria: { label: 'name' }, title: 'name' })
      end
    end

    context 'html label with suffix' do
      it 'sets aria-labels and titles using the label name provided' do
        options = set_accessible_properties('Change', { suffix: 'First Name' })
        expect(options).to eq({ aria: { label: 'Change First Name' }, suffix: 'First Name', title: 'Change First Name' })
      end
    end

    context 'html label with content tagging' do
      it 'sets aria-labels and titles using just the content of the label name provided' do
        options = set_accessible_properties('Start now <svg label="label"></svg>', {})
        expect(options).to eq({ aria: { label: 'Start now' }, title: 'Start now' })
      end
    end
  end
end
