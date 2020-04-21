# count the number of citizens that have denied open banking
#
module Dashboard
  module WidgetDataProviders
    class TotalDeclinedOpenBanking
      def self.dataset_definition
        {
          fields: [
            Geckoboard::NumberField.new(:total_declined_open_banking, name: 'Total declined open banking consent')
          ]
        }
      end

      def self.data
        total_declined_open_banking = LegalAidApplication.where('open_banking_consent=false').count
        [
          {
            'total_declined_open_banking' => total_declined_open_banking
          }
        ]
      end

      def self.handle
        'total_declined_open_banking'
      end
    end
  end
end
