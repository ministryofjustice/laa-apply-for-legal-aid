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
        [
          {
            'number' => Provider.all.group(:firm_id).count.size
          }
        ]
      end

      def self.handle
        'number_provider_firms'
      end
    end
  end
end
