module CCMS
  # This class is used to generate the next OPPONENT serial number in the CCMS payload for
  # opponents and involved children.  There will only ever be one such record in the table.
  #
  class OpponentId < ApplicationRecord
    SERIAL_ID_SEQUENCE_START = 88_000_000

    before_save :prevent_multiple_records

    def self.next_serial_id
      rec = first || build_new
      rec.serial_id += 1
      rec.save!
      rec.serial_id
    end

    def self.build_new
      new(serial_id: SERIAL_ID_SEQUENCE_START)
    end

  private

    def prevent_multiple_records
      return if self.class.none?

      raise "Attempted to write multiple CCMS::OpponentId records" if self.class.first&.id != id
    end
  end
end
