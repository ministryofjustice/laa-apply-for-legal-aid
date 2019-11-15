# Total number of submitted applications
#
module Dashboard
  module WidgetDataProviders
    class TotalSubmittedApplications
      def self.dataset_definition
        {
          fields: [
            Geckoboard::NumberField.new(:number, name: 'Applications')
          ]
        }
      end

      def self.data
        [
          {
            'number' => MeritsAssessment.count
          }
        ]
      end

      def self.handle
        'total_submitted_applications'
      end
    end
  end
end
