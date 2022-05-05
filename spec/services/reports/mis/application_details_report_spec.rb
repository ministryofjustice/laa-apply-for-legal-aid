require "rails_helper"

module Reports
  module MIS
    RSpec.describe ApplicationDetailsReport do
      let!(:unsubmitted_applications) do
        create_list :legal_aid_application, 3,
                    :with_proceedings,
                    :with_applicant,
                    :with_passported_state_machine
      end
      let!(:submitted_applications) do
        create_list :legal_aid_application, 3,
                    :with_passported_state_machine,
                    :with_applicant,
                    :with_proceedings,
                    :with_chances_of_success,
                    :at_assessment_submitted,
                    :with_merits_submitted_at
      end
      let!(:applications_being_submitted) do
        create :legal_aid_application,
               :with_passported_state_machine,
               :with_applicant,
               :with_proceedings,
               :with_chances_of_success,
               :at_submitting_assessment,
               :with_merits_submitted_at
      end
      let(:num_applications) { (unsubmitted_applications + submitted_applications + [applications_being_submitted]).flatten.size }
      let(:report) { described_class.new }

      describe "#run" do
        context "runs successfully" do
          it "the name of a file based on current date and time" do
            travel_to Time.zone.local(2022, 4, 27, 13, 22, 3).in_time_zone
            filename = report.run
            expect(filename.to_s).to match(/\/tmp\/admin_report_2022-04-27-13-22-03.csv$/)
            travel_back
          end

          it "writes a header line and 7 detail lines to the csv file" do
            filename = report.run
            lines = File.read(filename).split("\n")
            expect(lines.size).to eq num_applications + 1
          end
        end

        context "exception" do
          before { expect(report).to receive(:generate_temp_file).and_raise(RuntimeError) }

          it "notifies sentry" do
            expect(Sentry).to receive(:capture_message)
            report.run
          end
        end

        context "ApplicationDetailCsvLine exception" do
          before { allow_any_instance_of(ApplicationDetailCsvLine).to receive(:call).and_raise(StandardError, "fake error") }

          it "logs the error message" do
            expect(Rails.logger).to receive(:info).with("ApplicationDetailsReport - StandardError :: fake error")
            report.run
          end
        end
      end
    end
  end
end
