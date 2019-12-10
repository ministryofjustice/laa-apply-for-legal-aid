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
            'number' => MeritsAssessment.where('submitted_at IS NOT NULL').count
          }
        ]
      end

      def self.handle
        'total_submitted_applications'
      end
    end
  end
end
