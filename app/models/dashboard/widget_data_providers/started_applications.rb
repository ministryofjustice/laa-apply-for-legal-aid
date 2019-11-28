# count the number of applications started by day
#
module Dashboard
  module WidgetDataProviders
    class StartedApplications
      def self.dataset_definition
        {
          fields: [
            Geckoboard::DateField.new(:date, name: 'Date'),
            Geckoboard::NumberField.new(:number, name: 'Applications')
          ],
          unique_by: [:date]
        }
      end

      def self.data
        dates = (6.days.ago.to_date..Date.today).to_a
        result_set = []
        dates.each do |date|
          result_set << { 'date' => format_date(date), 'number' => started_applications(date) }
        end
        result_set
      end

      def self.handle
        'started_applications'
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
