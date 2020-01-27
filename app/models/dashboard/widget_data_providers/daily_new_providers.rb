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
        dates = (6.days.ago.to_date..Date.today).to_a
        result_set = []
        dates.each do |date|
          result_set << { 'date' => format_date(date), 'number' => signup_count(date) }
        end
        result_set
      end

      def self.format_date(date)
        date.strftime('%Y-%m-%d')
      end

      def self.signup_count(date)
        # if we're using whitelisted users, don't count providers that aren't in the whitelist
        if Rails.configuration.x.application.whitelisted_users
          Provider.where('DATE(created_at) = ? AND username IN (?)', date, Rails.configuration.x.application.whitelisted_users).count
        else
          Provider.where('DATE(created_at) = ?', date).count
        end
      end

      def self.handle
        'daily_new_providers'
      end
    end
  end
end
