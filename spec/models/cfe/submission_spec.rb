require "rails_helper"

RSpec.describe CFE::Submission do
  subject(:instance) { described_class.new }

  it { expect(instance).to delegate_method(:passported?).to(:legal_aid_application) }
  it { expect(instance).to delegate_method(:non_passported?).to(:legal_aid_application) }
  it { expect(instance).to delegate_method(:uploading_bank_statements?).to(:legal_aid_application) }
end
