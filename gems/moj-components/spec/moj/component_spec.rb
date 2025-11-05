# frozen_string_literal: true

RSpec.describe Moj::Component do
  it "has a version number" do
    expect(Moj::Component::VERSION).not_to be_nil
  end
end
