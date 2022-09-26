namespace :cfe do
  namespace :v5 do
    desc "Convert all CFE::V4:Result records that are really V5 to CFE::V5::Result"
    task convert: :environment do
      results = CFE::V4::Result.where.not(result: nil)
      results.each do |rec|
        hash = JSON.parse(rec.result)
        if hash["version"] == "5"
          rec.type = "CFE::V5::Result"
          rec.save!
        end
      end
    end
  end
end
