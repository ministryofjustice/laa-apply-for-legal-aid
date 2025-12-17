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
    self.dates = BankHolidayRetriever.dates if dates.blank?
  end
end
