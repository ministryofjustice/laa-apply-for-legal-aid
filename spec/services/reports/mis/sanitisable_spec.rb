require 'rails_helper'

module Reports
  module MIS
    class TestCsvLine
      include Sanitisable

      def initialize
        @line = ['+field_1', '-field_2', '=field_3', '@field_4', '%field_5']
      end
    end

    RSpec.describe Sanitisable do
      describe 'sanitise' do
        let(:test_line) { TestCsvLine.new }
        let(:sanitised_line) { ["'+field_1", "'-field_2", "'=field_3", "'@field_4", "'%field_5"] }

        it 'escapes all fields that begin with vulnerable characters' do
          expect(test_line.sanitise).to eq(sanitised_line)
        end
      end
    end
  end
end
