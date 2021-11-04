class DestroyPurgeableService
  START_OF_EPOCH = Date.new(1970, 1, 1).in_time_zone.freeze

  def self.call
    new.call
  end

  def call
    ids = LegalAidApplication.where(purgeable_on: START_OF_EPOCH..Time.zone.today, updated_at: START_OF_EPOCH..730.days.ago).pluck(:id)
    ids.each { |id| LegalAidApplication.find(id).destroy! }
  end
end
