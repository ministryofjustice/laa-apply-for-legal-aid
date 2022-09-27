require "rails_helper"

RSpec.describe ScopeLimitation do
  subject { described_class.new }

  it { is_expected.to define_enum_for(:scope_type).with_values(%i[substantive emergency]) }
end
