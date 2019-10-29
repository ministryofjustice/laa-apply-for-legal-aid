# count the number of providers created per day
#
module Dashboard
  module WidgetDataProviders
    class DailyNewProviders
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
        start_time = 7.days.ago
        result_set = query_database(start_time)
        dataset_query = []
        result_set.each { |row| dataset_query << row }
        dataset_query
      end

      def self.handle
        'daily_new_providers'
      end

      def self.query_database(start_time)
        sql = <<-EOSQL
          SELECT
            date(created_at) as date,
            count(*) as number
          FROM providers
          WHERE date(created_at) >= '#{start_time.strftime('%Y-%m-%d')} 00:00:00'
          GROUP BY date
          ORDER by date
        EOSQL
        LegalAidApplication.connection.execute(sql)
      end
    end
  end
end
