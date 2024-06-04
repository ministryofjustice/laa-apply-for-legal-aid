require "rails_helper"

RSpec.describe AddressHelper do
  describe ".address_with_line_breaks" do
    subject(:address_with_line_breaks) { helper.address_with_line_breaks(address) }

    let(:address) { create(:address) }

    context "when address is nil" do
      let(:address) { nil }

      it { is_expected.to be_nil }
    end

    context "when address is present" do
      it { is_expected.to eql "#{address.address_line_one}<br>#{address.address_line_two}<br>#{address.city}<br>#{address.county}<br>#{address.pretty_postcode}" }
    end
  end

  describe ".address_one_line" do
    subject(:address_one_line) { helper.address_one_line(address) }

    let(:address) { create(:address) }

    context "when address is nil" do
      let(:address) { nil }

      it { is_expected.to be_nil }
    end

    context "when address is present" do
      it { is_expected.to eql "#{address.address_line_one}, #{address.address_line_two}, #{address.city}, #{address.county}, #{address.pretty_postcode}" }
    end
  end
end
