require "rails_helper"

module CCMS
  RSpec.describe OpponentId do
    describe ".next_serial_id" do
      context "with no record in the ccms_opponent_ids table" do
        it "creates one record" do
          expect(described_class.count).to be_zero
          described_class.next_serial_id
          expect(described_class.count).to eq 1
        end

        it "returns the first valid value" do
          expect(described_class.count).to be_zero
          expect(described_class.next_serial_id).to eq 88_000_001
        end
      end

      context "when a record already exists in the ccms_opponent_ids table" do
        before { described_class.create!(serial_id: 88_123_456) }

        it "returns the next value" do
          expect(described_class.next_serial_id).to eq 88_123_457
        end

        it "has updated the count on the record" do
          described_class.next_serial_id
          expect(described_class.first.serial_id).to eq 88_123_457
        end

        it "does not add another record" do
          expect(described_class.count).to eq 1
          expect { described_class.next_serial_id }.not_to change(described_class, :count)
        end
      end
    end

    describe "prevent_multiple_records" do
      before { described_class.create!(serial_id: 88_123_567) }

      it "raises rather when attempting to save a second record" do
        expect {
          described_class.create!(serial_id: 12_345)
        }.to raise_error RuntimeError, "Attempted to write multiple CCMS::OpponentId records"
      end

      it "does not create the additional record" do
        begin
          described_class.create!(serial_id: 12_345)
        rescue StandardError
          nil
        end
        expect(described_class.count).to eq 1
      end
    end
  end
end
