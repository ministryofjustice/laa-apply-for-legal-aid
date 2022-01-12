require 'rails_helper'

module Reports
  module MIS
    RSpec.describe ApplicationDetailsReport do
      let!(:unsubmitted_applications) { create_list :legal_aid_application, 3, :with_proceedings, :with_passported_state_machine }
      let!(:submitted_applications) do
        create_list :legal_aid_application, 3,
                    :with_passported_state_machine,
                    :with_proceedings,
                    :with_chances_of_success,
                    :at_assessment_submitted,
                    :with_merits_submitted_at
      end
      let!(:applications_being_submitted) do
        create :legal_aid_application,
               :with_passported_state_machine,
               :with_proceedings,
               :with_chances_of_success,
               :at_submitting_assessment,
               :with_merits_submitted_at
      end
      let(:num_applications) { (unsubmitted_applications + submitted_applications + [applications_being_submitted]).flatten.size }
      let(:report) { described_class.new }

      describe '#run' do
        it 'returns a csv string with a header line' do
          csv_string = report.run
          lines = csv_string.split("\n")
          expect(lines.first).to match(/^Firm name,User name,Office ID/)
        end

        it 'returns a header and seven detail lines' do
          csv_string = report.run
          lines = csv_string.split("\n")
          expect(lines.size).to eq num_applications + 1
        end
      end
    end
  end
end
