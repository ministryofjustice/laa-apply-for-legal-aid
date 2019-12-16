module Dashboard
  module WidgetDataProviders
    class Applications
      def self.dataset_definition
        {
          fields: [
            Geckoboard::DateField.new(:date, name: 'Date'),
            Geckoboard::NumberField.new(:started_apps, name: 'Started applications'),
            Geckoboard::NumberField.new(:submitted_apps, name: 'Submitted applications'),
            Geckoboard::NumberField.new(:total_submitted_apps, name: 'Total submitted applications'),
            Geckoboard::NumberField.new(:failed_apps, name: 'Failed applications'),
            Geckoboard::NumberField.new(:delegated_func_apps, name: 'Delegated function applications')
          ],
          unique_by: [:date]
        }
      end

      def self.data
        dates = (6.days.ago.to_date..Date.today).to_a
        result_set = []
        dates.each do |date|
          result_set << {
            'date' => format_date(date),
            'started_apps' => started_applications(date),
            'submitted_apps' => submitted_applications(date),
            'total_submitted_apps' => total_submitted_applications(date),
            'failed_apps' => failed_ccms_submissions(date),
            'delegated_func_apps' => delegated_function_applications(date)
          }
        end
        result_set
      end

      def self.handle
        'applications'
      end

      def self.format_date(date)
        date.strftime('%Y-%m-%d')
      end

      def self.started_applications(date)
        LegalAidApplication.where('DATE(created_at) = ?', date).count
      end

      def self.submitted_applications(date)
        MeritsAssessment.where('DATE(submitted_at) = ?', date).count
      end

      def self.total_submitted_applications(date)
        MeritsAssessment.where('DATE(submitted_at) <= ?', date).count
      end

      def self.failed_ccms_submissions(date)
        CCMS::Submission.where('DATE(created_at) = ? AND aasm_state = ?', date, 'failed').count
      end

      def self.delegated_function_applications(date)
        LegalAidApplication.where('used_delegated_functions=true AND DATE(created_at) = ?', date).count
      end
    end
  end
end
