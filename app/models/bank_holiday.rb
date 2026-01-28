class BankHoliday < ApplicationRecord
  serialize :dates, type: Array, coder: YAML

  scope :by_updated_at, -> { order(updated_at: :asc) }
  before_validation :populate_dates

  validates :dates, presence: true

  def self.dates
    instance = by_updated_at.last || create!
    instance.dates
  end

  def populate_dates
    if dates.blank?
      self.dates = latest_dates
      BankHolidayStore.write(latest_dates)
    end
  end

private

  def latest_dates
    @latest_dates ||= BankHolidayRetriever.dates
  end
end
