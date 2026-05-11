require "rails_helper"

RSpec.describe Datastore::TokenExchangeError do
  subject(:instance) { described_class.new(error_response) }

  let(:error_response) do
    {
      "error" => "invalid_something",
      "error_description" => "AADSTS111111: Some error has occurred on token exchange...",
    }
  end

  it "has response attribute" do
    expect(instance).to have_attributes(response: error_response)
  end

  it "has a message that includes error and error description from response" do
    expect(instance.message).to eq("Microsoft token exchange failed: invalid_something: AADSTS111111: Some error has occurred on token exchange...")
  end
end
