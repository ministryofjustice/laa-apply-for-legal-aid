require "rails_helper"

RSpec.describe LinkedApplication do
  subject(:linked_application) { build(:linked_application, lead_application:, associated_application:) }

  let(:lead_application) { build(:legal_aid_application) }
  let(:associated_application) { build(:legal_aid_application) }

  it { expect(linked_application.lead_application).to eq lead_application }
  it { expect(linked_application.associated_application).to eq associated_application }
  it { expect(linked_application.link_type_code).to eq "FAMILY" }
end
