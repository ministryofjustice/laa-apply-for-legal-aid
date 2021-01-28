require 'rails_helper'

RSpec.describe HtmlPageSaver do
  describe '.call' do
    let(:html) { '<html><head><meta charset="utf-8"><meta a="b"></head></html>' }
    let(:file_path) { Rails.root.join('tmp/page.html') }
    let(:asset_host) { 'http://localhost:3004' }
    let(:expected_html) { html.sub('"utf-8">', '"utf-8"><base href="http://localhost:3004" />') }
    let(:expected_file) { File.expand_path(file_path) }

    subject { described_class.call(html: html, file_path: file_path, asset_host: asset_host) }

    before { expect(File).to receive(:write).with(expected_file, expected_html, mode: 'wb') }

    it 'writes the right html to the right file' do
      subject
    end

    context 'html does not have meta charset' do
      let(:html) { '<html><head><meta a="b"></head></html>' }
      let(:expected_html) { html.sub('head>', 'head><base href="http://localhost:3004" />') }

      it 'writes the base tag after <head>' do
        subject
      end
    end

    context 'html does not have <head>' do
      let(:html) { '<html></html>' }
      let(:expected_html) { html }

      it 'does not crash' do
        subject
      end
    end
  end
end
