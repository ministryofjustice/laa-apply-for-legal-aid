# count the number of failed CCMS submissions by day over the last week
#
module Dashboard
  module WidgetDataProviders
    class FailedCCMSSubmissions
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
        start_time = 7.days.ago
        result_set = query_database(start_time)
        dataset_query = []
        result_set.each { |row| dataset_query << row }
        dataset_query
        [{"date"=>"2019-11-08", "number"=>1}, {"date"=>"2019-11-12", "number"=>2}, {"date"=>"2019-11-13", "number"=>1}]
      end

      def self.handle
        'ccms_submission_failures'
      end

      def self.query_database(start_time)
        sql = <<-EOSQL
          SELECT
            date(created_at) as date,
            count(*) as number
          FROM ccms_submissions
          WHERE date(created_at) >= '#{start_time.strftime('%Y-%m-%d')} 00:00:00'
            AND aasm_state = 'failed'
          GROUP BY date
          ORDER by date
        EOSQL
        LegalAidApplication.connection.execute(sql)
      end
    end
  end
end
