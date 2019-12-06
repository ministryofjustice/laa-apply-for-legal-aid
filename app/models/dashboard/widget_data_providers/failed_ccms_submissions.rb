# count the number of failed CCMS submissions by day over the last week
#
module Dashboard
  module WidgetDataProviders
    class FailedCcmsSubmissions
      def self.dataset_definition
        {
          fields: [
            Geckoboard::DateField.new(:date, name: 'Date'),
            Geckoboard::NumberField.new(:number, name: 'Submissions')
          ],
          unique_by: [:date]
        }
      end

      def self.data
        dates = (6.days.ago.to_date..Date.today).to_a
        result_set = []
        dates.each do |date|
          result_set << {
            'date' => date.strftime('%Y-%m-%d'),
            'number' => failure_count(date)
          }
        end
        result_set
      end

      def self.handle
        'ccms_submission_failures'
      end

      def self.failure_count(date)
        CCMS::Submission.where('DATE(created_at) = ? AND aasm_state = ?', date, 'failed').count
      end
    end
  end
end
