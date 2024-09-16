require "rails_helper"
require "sidekiq/testing"

RSpec.describe ProviderContractDetailsWorker do
  subject(:perform) { described_class.new.perform(office_code) }

  let(:office_code) { "A1345X1" }

  it "calls PDA::CurrentContracts" do
    expect(PDA::CurrentContracts).to receive(:call).with(office_code).once
    perform
  end
end
