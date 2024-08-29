require "rails_helper"
require "sidekiq/testing"

RSpec.describe CompareProviderDetailsWorker do
  subject(:perform) { described_class.new.perform(provider.id) }

  let(:provider) { create(:provider) }

  it "calls PDA::CompareProviderDetails" do
    expect(PDA::CompareProviderDetails).to receive(:call).with(provider.id).once
    perform
  end
end
