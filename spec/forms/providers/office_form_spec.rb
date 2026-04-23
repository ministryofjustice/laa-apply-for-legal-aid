require "rails_helper"

RSpec.describe Providers::OfficeForm do
  subject(:office_form) { described_class.new(params) }

  let(:provider) { create :provider, office_codes: "0X395U:2N078D:A123456" }
  let(:params) { { selected_office_code:, model: provider } }

  context "when the select_office_id param in included in the current_provider office_codes" do
    let(:selected_office_code) { "0X395U" }

    it { is_expected.to be_valid }
  end

  context "when the select_office_id is not included in the current_provider office_codes" do
    let(:selected_office_code) { "1X111X" }

    it { is_expected.not_to be_valid }
  end
end
