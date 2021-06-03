FactoryBot.define do
  factory :admin_report do
    trait :with_reports_attached do
      after :create do |admin_report|
        csv_string = CSV.generate do |csv|
          csv << %w[col1 col2 col3]
        end
        admin_report.non_passported_applications.attach io: StringIO.new(csv_string), filename: 'non_passported_applications_report', content_type: 'text/csv'
        admin_report.submitted_applications.attach io: StringIO.new(csv_string), filename: 'submitted_applications_report', content_type: 'text/csv'
      end
    end
  end
end
