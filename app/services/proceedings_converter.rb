class ProceedingsConverter
  def call
    LegalAidApplication.all.each do |application|
      application.application_proceeding_types.each do |proceeding|
        next if application.proceedings.count == application.application_proceeding_types.count

        ProceedingSyncService.new(proceeding).create!
      end
    end
  end
end
