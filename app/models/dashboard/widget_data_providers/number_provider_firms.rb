# count the number of provider firms that have ever logged in
#
module Dashboard
  module WidgetDataProviders
    class NumberProviderFirms
      def self.dataset_definition
        {
          fields: [
            Geckoboard::NumberField.new(:number, name: 'Firms')
          ]
        }
      end

      def self.data
        # if we're using whitelisted users, don't count firms that belong to users that aren't in the whitelist
        provider_count = if Rails.configuration.x.application.whitelisted_users
                           Provider.where(username: Rails.configuration.x.application.whitelisted_users).group(:firm_id).count.size
                         else
                           Provider.all.group(:firm_id).count.size
                         end
        [
          {
            'number' => provider_count
          }
        ]
      end

      def self.handle
        'number_provider_firms'
      end
    end
  end
end
