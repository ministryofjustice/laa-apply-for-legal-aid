FactoryBot.define do
  factory :admin_report do
    trait :with_reports_attached do
      after :create do |admin_report|
        csv_string = CSV.generate do |csv|
          csv << %w[col1 col2 col3]
        end
        admin_report.application_details_report.attach io: StringIO.new(csv_string), filename: 'application_details_report', content_type: 'text/csv'
      end
    end
  end
end
