require 'rails_helper'

module Reports
  module MIS
    RSpec.describe ApplicationDetailsReport do
      let!(:unsubmitted_applications) { create_list :legal_aid_application, 3 }
      let!(:submitted_applications) { create_list :legal_aid_application, 3, :at_assessment_submitted }
      let(:report) { described_class.new }

      describe '#run' do
        it 'gets only applications in assessment submitted state' do
          expect(LegalAidApplication).to receive(:assessment_submitted).and_call_original
          report.run
        end

        it 'returns a csv string with a header line' do
          csv_string = report.run
          lines = csv_string.split("\n")
          expect(lines.first).to match(/^Firm name,User name,Office ID/)
        end

        it 'returns a header and three detail lines' do
          csv_string = report.run
          lines = csv_string.split("\n")
          expect(lines.size).to eq 4
        end
      end
    end
  end
end
