require "rails_helper"

RSpec.describe CFE::Submission, type: :model do
  subject(:instance) { described_class.new }

  it { expect(instance).to delegate_method(:passported?).to(:legal_aid_application) }
  it { expect(instance).to delegate_method(:non_passported?).to(:legal_aid_application) }
  it { expect(instance).to delegate_method(:using_enhanced_bank_upload?).to(:legal_aid_application) }
end
