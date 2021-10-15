class ApplicationDigest < ApplicationRecord

  def as_json(options = nil)
    {
      providerName: name,
      dateStarted: formatted_date(date_started),
      dateSubmitted: formatted_date(date_submitted),
      daysToSubmission: days_to_submission.nil? ? 0 : days_to_submission,
      submitted: submitted,
      numApplications: num_applications
    }
  end

  def submitted
    date_submitted.nil? ? 'FALSE' : 'TRUE'
  end

  def num_applications
    1
  end

  def formatted_date(date)
    return '19700101' if date.nil?

    date.strftime('%Y%m%d')
  end


  def self.to_csv
    attributes = %w{name date_started date_submitted days_to_submission submitted num_applications}

    CSV.open("myfile.csv", "w") do |csv|
      csv << attributes
      all.each do |record|
        arr = []
        csv << attributes.map{ |attr| record.send(attr) }
      end
    end

    # CSV.generate(headers: true) do |csv|
    #   csv << attributes
    #
    #   all.each do |record|
    #     csv << attributes.map{ |attr| record.send(attr) }
    #   end
    # end
  end
end
