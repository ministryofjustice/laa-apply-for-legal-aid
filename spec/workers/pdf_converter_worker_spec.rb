require 'rails_helper'

RSpec.describe PdfConverterWorker, type: :worker do
  let(:uuid) { SecureRandom.uuid }

  it 'calls PdfConverter' do
    expect(PdfConverter).to receive(:call).with(uuid)
    described_class.new.perform(uuid)
  end
end
