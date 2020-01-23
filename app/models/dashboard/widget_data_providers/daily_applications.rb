module Dashboard
  module WidgetDataProviders
    class DailyApplications
      def self.dataset_definition
        {
          fields: [
            Geckoboard::DateField.new(:date, name: 'Date'),
            Geckoboard::NumberField.new(:daily_apps, name: 'Daily applications')
          ],
          unique_by: [:date]
        }
      end

      def self.data
        date = Date.today
        result_set = []
        result_set << {
          'date' => format_date(date),
          'daily_apps' => started_applications(date)
        }
        result_set
      end

      def self.handle
        'daily_applications'
      end

      def self.format_date(date)
        date.strftime('%Y-%m-%d')
      end

      def self.started_applications(date)
        LegalAidApplication.where('DATE(created_at) = ?', date).count
      end
    end
  end
end
